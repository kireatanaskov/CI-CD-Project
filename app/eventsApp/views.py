from datetime import datetime
from django.shortcuts import render, redirect
from .models import Event
from .forms import EventForm


def add_event(request):
    form = EventForm()
    all_events_in_future = Event.objects.filter(date__gte=datetime.now().date()).all()
    extra_context = {'form': form, 'all_events': all_events_in_future}
    if request.method == 'POST':
        event_form = EventForm(request.POST, files=request.FILES)
        if event_form.is_valid():
            event = event_form.save(commit=False)
            event.poster = event_form.cleaned_data['poster']
            event.user = request.user
            event.save()
            return redirect('/')
    return render(request, 'add_event.html', context=extra_context)


def events(request):
    events1 = Event.objects.all()

    return render(request, 'index.html', {'events': events1, 'new_var': 1})


def edit_event(request, id):
    event = Event.objects.filter(id=id).get()
    if request.method == 'POST':
        event = EventForm(request.POST, instance=event)
        if event.is_valid():
            event.save()
        return redirect('/')
    else:
        event = EventForm(instance=event)

    return render(request, 'edit_event.html', {'form': event})


def delete_event(request, id):
    event = Event.objects.filter(id=id).get()
    if request.method == 'POST':
        event.delete()
        return redirect('/')

    return render(request, 'delete_event.html')
