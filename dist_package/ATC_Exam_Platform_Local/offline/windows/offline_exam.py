import random
import sqlite3
import sys
import tkinter as tk
from pathlib import Path
from tkinter import messagebox

QUESTION_COUNT = 50


def bundled_path(relative_path):
    if hasattr(sys, "_MEIPASS"):
        return Path(sys._MEIPASS) / relative_path
    return Path(__file__).resolve().parent.parent / relative_path


DB_PATH = bundled_path(Path("data") / "offline_exam.db")


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

        self.subject_var = tk.StringVar(value="APS")
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

    def show_start_screen(self):
        self.clear_container()
        title = tk.Label(self.container, text="Thi thử offline", bg="#0a2a66", fg="white", font=("Arial", 22, "bold"))
        title.pack(pady=12)

        frm = tk.Frame(self.container, bg="#0a2a66")
        frm.pack(pady=8)
        tk.Label(frm, text="Chọn nhóm đề:", bg="#0a2a66", fg="white", font=("Arial", 14)).pack(side="left", padx=8)
        for code in ("APS", "ADC", "ACC HAN", "SUP"):
            tk.Radiobutton(
                frm,
                text=code,
                variable=self.subject_var,
                value=code,
                bg="#0a2a66",
                fg="white",
                selectcolor="#0a2a66",
            ).pack(side="left", padx=8)

        tk.Button(self.container, text="Bắt đầu thi 50 câu", command=self.start_exam, bg="white", fg="#0a2a66", font=("Arial", 12, "bold")).pack(pady=14)

        info = tk.Label(self.container, text=f"Nguồn dữ liệu: {DB_PATH.name}", bg="#0a2a66", fg="white")
        info.pack(pady=6)

    def start_exam(self):
        subject = self.subject_var.get()
        pool = self.load_pool(subject)
        if len(pool) < QUESTION_COUNT:
            messagebox.showwarning("Thiếu dữ liệu", f"Nhóm {subject} chỉ có {len(pool)} câu, chưa đủ {QUESTION_COUNT}.")
            return

        self.current_exam = random.sample(pool, QUESTION_COUNT)
        random.shuffle(self.current_exam)
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
