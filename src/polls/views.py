from django.http import HttpRequest, HttpResponse


def index(_: HttpRequest):
    return HttpResponse("Hello, world. You're at the polls index.")
