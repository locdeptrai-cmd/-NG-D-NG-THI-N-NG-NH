import json
import os
import random
import re
import sqlite3
import sys
import tkinter as tk
from pathlib import Path
from tkinter import messagebox

QUESTION_COUNTS = (20, 50, 100)
# Prefer 35% TSN; step down to 25% then 15%. If TSN share of the eligible pool
# is under 15% (or TSN is empty), balance equally by knowledge category instead.
TSN_PERCENT_FALLBACKS = (35, 25, 15)
TSN_PERCENT = TSN_PERCENT_FALLBACKS[0]
TSN_BANK_MIN_PERCENT = 15
RECENT_EXAM_EXCLUSION_LIMIT = 6
CATEGORY_ONLY_SUBJECTS = frozenset(
    {"ACC HAN", "ACS SUP HCM", "SUP ACS HAN"}
)


def uses_tsn_ratio(subject_code):
    return str(subject_code or "").strip().upper() not in {
        item.upper() for item in CATEGORY_ONLY_SUBJECTS
    }


def offline_db_path():
    if hasattr(sys, "_MEIPASS"):
        return Path(sys._MEIPASS) / "offline_exam.db"
    return Path(__file__).resolve().parent.parent / "dist" / "offline_exam.db"


DB_PATH = offline_db_path()
HISTORY_PATH = (
    Path(os.getenv("LOCALAPPDATA", Path.home()))
    / "ATC_Offline_Exam"
    / "question_history.json"
)


def is_tsn_question(question):
    text = " ".join(
        [question.get("code", ""), question.get("content", "")]
    ).upper()
    return bool(
        re.search(r"(^|[^A-Z0-9])TSN([^A-Z0-9]|$)", text)
        or "TÂN SƠN NHẤT" in text
        or "TAN SON NHAT" in text
        or "TANSONNHAT" in text
    )


def tsn_share_percent(tsn_available, pool_size):
    if pool_size <= 0:
        return 0.0
    return 100.0 * tsn_available / pool_size


def should_apply_tsn_split(tsn_available, pool_size):
    if tsn_available <= 0:
        return False
    return tsn_share_percent(tsn_available, pool_size) >= TSN_BANK_MIN_PERCENT


def tsn_target_count(total, percent=None):
    if total not in QUESTION_COUNTS:
        raise ValueError("Số câu chỉ được chọn 20, 50 hoặc 100.")
    ratio = TSN_PERCENT if percent is None else percent
    if ratio not in TSN_PERCENT_FALLBACKS:
        raise ValueError(f"Tỷ lệ TSN không hợp lệ: {ratio}.")
    return int(total * ratio / 100 + 0.5)


def resolve_tsn_percent(tsn_available, other_available, total):
    """Highest feasible TSN percent, or None to balance equally by category."""
    pool_size = tsn_available + other_available
    if not should_apply_tsn_split(tsn_available, pool_size):
        return None
    for percent in TSN_PERCENT_FALLBACKS:
        tsn_need = tsn_target_count(total, percent)
        other_need = total - tsn_need
        if tsn_available >= tsn_need and other_available >= other_need:
            return percent, tsn_need, other_need
    return None


def balanced_take(questions, count, rng):
    buckets = {}
    for question in questions:
        buckets.setdefault(question.get("category") or "Khác", []).append(question)
    keys = list(buckets)
    rng.shuffle(keys)
    for bucket in buckets.values():
        rng.shuffle(bucket)

    selected = []
    while len(selected) < count:
        progressed = False
        for key in keys:
            if not buckets[key]:
                continue
            selected.append(buckets[key].pop())
            progressed = True
            if len(selected) == count:
                break
        if not progressed:
            break
    return selected


def select_balanced_exam(pool, total, excluded_ids=None, subject_code=None, rng=None):
    rng = rng or random.SystemRandom()
    excluded_ids = set(excluded_ids or [])
    seen_ids = set()
    available = []
    for item in pool:
        question_id = item["id"]
        if question_id in excluded_ids or question_id in seen_ids:
            continue
        seen_ids.add(question_id)
        available.append(item)

    code = subject_code or (available[0].get("subject") if available else None)
    if uses_tsn_ratio(code):
        tsn_pool = [item for item in available if is_tsn_question(item)]
        other_pool = [item for item in available if not is_tsn_question(item)]
        resolved = resolve_tsn_percent(len(tsn_pool), len(other_pool), total)
        if resolved is None:
            if len(available) < total:
                raise ValueError(
                    f"Ngân hàng chỉ còn {len(available)} câu; cần {total} câu."
                )
            selected = balanced_take(available, total, rng)
        else:
            _percent, tsn_count, other_count = resolved
            selected = [
                *balanced_take(tsn_pool, tsn_count, rng),
                *balanced_take(other_pool, other_count, rng),
            ]
    else:
        if len(available) < total:
            raise ValueError(
                f"Ngân hàng chỉ còn {len(available)} câu; cần {total} câu."
            )
        selected = balanced_take(available, total, rng)

    unique = []
    unique_ids = set()
    for item in selected:
        if item["id"] in unique_ids:
            continue
        unique_ids.add(item["id"])
        unique.append(item)
    if len(unique) != total:
        raise ValueError(
            f"Không tạo được đề {total} câu không trùng "
            f"(chỉ chọn được {len(unique)} câu)."
        )
    rng.shuffle(unique)
    return unique


def normalize_subject_history(value):
    """Return list of up to N prior exams, each exam a list of question ids."""
    if not value:
        return []
    if isinstance(value, list) and value and isinstance(value[0], list):
        exams = []
        for exam in value:
            if not isinstance(exam, list):
                continue
            exams.append([int(question_id) for question_id in exam])
        return exams[-RECENT_EXAM_EXCLUSION_LIMIT:]
    # Legacy flat list = one previous exam.
    try:
        return [[int(question_id) for question_id in value]]
    except (TypeError, ValueError):
        return []


def excluded_ids_from_history(history, subject):
    excluded = set()
    for exam_ids in normalize_subject_history(history.get(subject)):
        excluded.update(exam_ids)
    return excluded


class OfflineExamApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("ATC Offline Exam - Windows")
        self.geometry("980x720")
        self.configure(bg="#0a2a66")

        self.conn = self.open_db()
        self.current_exam = []
        self.current_index = 0
        self.user_answers = {}
        self.question_history = self.load_history()

        self.subject_var = tk.StringVar(value="APS")
        self.count_var = tk.IntVar(value=50)
        self.container = tk.Frame(self, bg="#0a2a66")
        self.container.pack(fill="both", expand=True, padx=16, pady=16)

        self.show_start_screen()

    def open_db(self):
        if not DB_PATH.exists():
            messagebox.showerror("Lỗi", f"Không tìm thấy DB: {DB_PATH}")
            self.destroy()
            raise SystemExit(1)
        return sqlite3.connect(DB_PATH)

    def load_pool(self, subject):
        cur = self.conn.cursor()
        cur.execute(
            "SELECT id, code, subject, category, content, explanation, question_type FROM questions WHERE subject = ?",
            (subject,),
        )
        questions = []
        for row in cur.fetchall():
            qid, code, sub, cat, content, explanation, qtype = row
            cur.execute(
                "SELECT id, label, content, is_correct FROM answers WHERE question_id = ? ORDER BY ord, id",
                (qid,),
            )
            answers = [
                {"id": a[0], "label": a[1], "content": a[2], "is_correct": bool(a[3])}
                for a in cur.fetchall()
            ]
            if len(answers) < 2:
                continue
            questions.append(
                {
                    "id": qid,
                    "code": code,
                    "subject": sub,
                    "category": cat,
                    "content": content,
                    "explanation": explanation or "",
                    "question_type": qtype or "single",
                    "answers": answers,
                }
            )
        return questions

    def clear_container(self):
        for w in self.container.winfo_children():
            w.destroy()

    def load_history(self):
        try:
            raw = json.loads(HISTORY_PATH.read_text(encoding="utf-8"))
        except (OSError, ValueError, TypeError):
            return {}
        if not isinstance(raw, dict):
            return {}
        return {
            subject: normalize_subject_history(value)
            for subject, value in raw.items()
        }

    def save_history(self):
        try:
            HISTORY_PATH.parent.mkdir(parents=True, exist_ok=True)
            HISTORY_PATH.write_text(
                json.dumps(self.question_history, ensure_ascii=False, indent=2),
                encoding="utf-8",
            )
        except OSError:
            pass

    def excluded_question_ids(self, subject):
        return excluded_ids_from_history(self.question_history, subject)

    def remember_exam(self, subject, question_ids):
        exams = normalize_subject_history(self.question_history.get(subject))
        exams.append([int(question_id) for question_id in question_ids])
        self.question_history[subject] = exams[-RECENT_EXAM_EXCLUSION_LIMIT:]
        self.save_history()

    def show_start_screen(self):
        self.clear_container()
        title = tk.Label(self.container, text="Thi thử offline", bg="#0a2a66", fg="white", font=("Arial", 22, "bold"))
        title.pack(pady=12)

        frm = tk.Frame(self.container, bg="#0a2a66")
        frm.pack(pady=8)
        tk.Label(frm, text="Chọn nhóm đề:", bg="#0a2a66", fg="white", font=("Arial", 14)).pack(side="left", padx=8)
        for code in (
            "APS",
            "ADC",
            "ACC HAN",
            "SUP",
            "SUP ACS HAN",
            "ACS SUP HCM",
        ):
            tk.Radiobutton(
                frm,
                text=code,
                variable=self.subject_var,
                value=code,
                bg="#0a2a66",
                fg="white",
                selectcolor="#0a2a66",
            ).pack(side="left", padx=8)

        count_frame = tk.Frame(self.container, bg="#0a2a66")
        count_frame.pack(pady=8)
        tk.Label(
            count_frame,
            text="Số câu:",
            bg="#0a2a66",
            fg="white",
            font=("Arial", 14),
        ).pack(side="left", padx=8)
        for count in QUESTION_COUNTS:
            tk.Radiobutton(
                count_frame,
                text=str(count),
                variable=self.count_var,
                value=count,
                bg="#0a2a66",
                fg="white",
                selectcolor="#0a2a66",
            ).pack(side="left", padx=8)

        tk.Label(
            self.container,
            text=(
                "APS/ADC/SUP: ≥15% TSN thì ưu tiên 35%/25%/15%; dưới 15% hoặc "
                "hết TSN thì chia đều loại kiến thức. "
                "ACC HAN/ACS: chia đều loại kiến thức, không TSN. "
                "Không lặp 6 bài gần nhất."
            ),
            bg="#0a2a66",
            fg="white",
        ).pack(pady=6)
        tk.Button(
            self.container,
            text="Bắt đầu thi",
            command=self.start_exam,
            bg="white",
            fg="#0a2a66",
            font=("Arial", 12, "bold"),
        ).pack(pady=14)

        info = tk.Label(self.container, text=f"Nguồn dữ liệu: {DB_PATH.name}", bg="#0a2a66", fg="white")
        info.pack(pady=6)

    def start_exam(self):
        subject = self.subject_var.get()
        question_count = self.count_var.get()
        pool = self.load_pool(subject)
        try:
            self.current_exam = select_balanced_exam(
                pool,
                question_count,
                excluded_ids=self.excluded_question_ids(subject),
                subject_code=subject,
            )
        except ValueError as exc:
            messagebox.showwarning("Thiếu dữ liệu", str(exc))
            return

        self.current_index = 0
        self.user_answers = {}
        self.show_question()

    def show_question(self):
        self.clear_container()
        q = self.current_exam[self.current_index]

        top = tk.Frame(self.container, bg="#0a2a66")
        top.pack(fill="x")
        tk.Label(top, text=f"Câu {self.current_index + 1}/{len(self.current_exam)}", bg="#0a2a66", fg="white", font=("Arial", 14, "bold")).pack(side="left")

        card = tk.Frame(self.container, bg="white", bd=1, relief="solid")
        card.pack(fill="both", expand=True, pady=12)

        tk.Label(card, text=q["content"], bg="white", fg="#0a2a66", justify="left", wraplength=900, font=("Arial", 12, "bold")).pack(anchor="w", padx=12, pady=12)

        var = tk.StringVar(value=self.user_answers.get(self.current_index, ""))
        for ans in q["answers"]:
            val = str(ans["id"])
            tk.Radiobutton(
                card,
                text=f"{ans['label']}. {ans['content']}",
                variable=var,
                value=val,
                bg="white",
                fg="#0a2a66",
                anchor="w",
                justify="left",
                wraplength=900,
                selectcolor="white",
            ).pack(fill="x", padx=16, pady=4)

        bottom = tk.Frame(self.container, bg="#0a2a66")
        bottom.pack(fill="x", pady=8)

        def save_choice():
            self.user_answers[self.current_index] = var.get()

        def prev_q():
            save_choice()
            if self.current_index > 0:
                self.current_index -= 1
                self.show_question()

        def next_q():
            save_choice()
            if self.current_index < len(self.current_exam) - 1:
                self.current_index += 1
                self.show_question()

        def submit():
            save_choice()
            self.finish_exam()

        tk.Button(bottom, text="Câu trước", command=prev_q, bg="white", fg="#0a2a66").pack(side="left")
        tk.Button(bottom, text="Câu tiếp", command=next_q, bg="white", fg="#0a2a66").pack(side="left", padx=8)
        tk.Button(bottom, text="Nộp bài", command=submit, bg="white", fg="#0a2a66", font=("Arial", 11, "bold")).pack(side="right")

    def finish_exam(self):
        correct = 0
        for idx, q in enumerate(self.current_exam):
            chosen = self.user_answers.get(idx, "")
            correct_ids = {str(a["id"]) for a in q["answers"] if a.get("is_correct")}
            if chosen and chosen in correct_ids and len(correct_ids) == 1:
                correct += 1

        score = round((correct / len(self.current_exam)) * 10, 2)
        subject = self.current_exam[0]["subject"]
        self.remember_exam(subject, [item["id"] for item in self.current_exam])
        self.show_result(score, correct, len(self.current_exam))

    def show_result(self, score, correct, total):
        self.clear_container()
        tk.Label(self.container, text="Kết quả thi", bg="#0a2a66", fg="white", font=("Arial", 22, "bold")).pack(pady=20)
        tk.Label(self.container, text=f"Điểm: {score}/10", bg="#0a2a66", fg="white", font=("Arial", 16, "bold")).pack(pady=8)
        tk.Label(self.container, text=f"Số câu đúng: {correct}/{total}", bg="#0a2a66", fg="white", font=("Arial", 14)).pack(pady=8)
        tk.Button(self.container, text="Làm bài mới", command=self.show_start_screen, bg="white", fg="#0a2a66", font=("Arial", 12, "bold")).pack(pady=20)


if __name__ == "__main__":
    app = OfflineExamApp()
    app.mainloop()
