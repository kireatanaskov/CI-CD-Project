from django.db import models


class Event(models.Model):
    name = models.CharField(max_length=50)
    date = models.DateField()
    poster = models.ImageField(upload_to='images/')
    open_air = models.BooleanField(default=False)

    def __str__(self):
        return self.name
