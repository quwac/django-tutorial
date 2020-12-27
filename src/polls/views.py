from django.http import HttpRequest, HttpResponse
from django.shortcuts import get_object_or_404, render

from polls.models import Question


def index(request: HttpRequest) -> HttpResponse:
    latest_question_list = Question.objects.order_by("-pub_date")[:5]
    return render(request, "polls/index.html", {"latest_question_list": latest_question_list})


def detail(request: HttpRequest, question_id: int) -> HttpResponse:
    question: Question = get_object_or_404(Question, pk=question_id)
    return render(request, "polls/detail.html", {"question": question})


def results(request: HttpRequest, question_id: int) -> HttpResponse:
    response = "You're looking at the results of question %s."
    return HttpResponse(response % question_id)


def vote(request: HttpRequest, question_id: int) -> HttpResponse:
    return HttpResponse("You're voting on questions %s." % question_id)  # noqa: FS001
