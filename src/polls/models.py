import datetime

from django.db import models
from django.utils import timezone


class Question(models.Model):
    question_text = models.CharField(max_length=200)
    pub_date = models.DateTimeField("date published")

    def was_published_recentry(self) -> bool:
        sub = timezone.now() - datetime.timedelta(days=1)
        return self.pub_date >= sub  # pyright:  reportUnknownVariableType = false

    def __str__(self) -> str:
        return self.question_text


class Choice(models.Model):
    question = models.ForeignKey(
        Question, on_delete=models.CASCADE
    )  # pyright: reportUnknownArgumentType = false
    choice_text = models.CharField(max_length=200)
    votes = models.IntegerField(default=0)

    def __str__(self) -> str:
        return self.choice_text
