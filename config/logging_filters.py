import logging


class IgnoreBrokenPipeFilter(logging.Filter):
    def filter(self, record):
        message = record.getMessage()
        return "Broken pipe from" not in message
