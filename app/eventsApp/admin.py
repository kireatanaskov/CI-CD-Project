from django.contrib import admin

from .models import *

# Register your models here.


class EventAdmin(admin.ModelAdmin):
    list_display = ['name', 'date']

    def has_add_permission(self, request):
        return request.user.is_superuser

    def save_model(self, request, obj, form, change):
        obj.user = request.user
        return super(EventAdmin, self).save_model(request, obj, form, change)

    def has_delete_permission(self, request, obj=None):
        return obj and obj.user == request.user

    def has_change_permission(self, request, obj=None):
        return obj and obj.user == request.user


admin.site.register(Event, EventAdmin)
