from django import forms
from .models import Event


class EventForm(forms.ModelForm):
    def __init__(self, *args, **kwargs):
        super(EventForm, self).__init__(*args, **kwargs)
        excluded_field_name = 'open_air'
        for field in self.visible_fields():
            if field.name != excluded_field_name:
                field.field.widget.attrs['class'] = 'form-control w-25'
                field.field.widget.attrs['placeholder'] = field.label

    class Meta:
        model = Event
        fields = '__all__'