from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth import get_user_model

from .models import Pickup, Product, DriverDetails, Report, Bill, BillItem

User = get_user_model()


@admin.register(User)
class CustomUserAdmin(UserAdmin):
    list_display = ("username", "email", "phone_number", "role", "is_staff", "is_active")
    list_filter = ("role", "is_staff", "is_active")
    fieldsets = UserAdmin.fieldsets + (
        ("Extra fields", {"fields": ("role", "phone_number", "address")}),
    )
    add_fieldsets = UserAdmin.add_fieldsets + (
        ("Extra fields", {"fields": ("role", "phone_number", "address")}),
    )


@admin.register(Pickup)
class PickupAdmin(admin.ModelAdmin):
    # show choice labels instead of stored values
    list_display = (
        "id",
        "user",
        "date",
        "time_slot_label",
        "manpower_label",
        "weight",
        "status",
        "created_at",
    )
    list_filter = ("status", "date", "created_at")
    search_fields = ("user__username", "id")
    readonly_fields = ("created_at", "updated_at")

    @admin.display(description="Time slot", ordering="time_slot")
    def time_slot_label(self, obj):
        return obj.get_time_slot_display()

    @admin.display(description="Manpower", ordering="manpower")
    def manpower_label(self, obj):
        # works only if manpower has choices=
        try:
            return obj.get_manpower_display()
        except Exception:
            return obj.manpower


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "product_icon",
        "product_name",
        "product_description",
        "product_price",
        "product_category",
        "created_at",
    )
    list_filter = ("product_category", "created_at")
    search_fields = ("product_name", "product_category", "product_description")
    readonly_fields = ("created_at",)


@admin.register(DriverDetails)
class DriverDetailsAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "driver_name",
        "vehicle_number",
        "phone_number",
        "email_id",
        "status",
        "created_at",
    )
    list_filter = ("status", "created_at")
    search_fields = ("driver_name", "vehicle_number", "phone_number", "email_id")
    readonly_fields = ("created_at", "updated_at")


@admin.register(Report)
class ReportAdmin(admin.ModelAdmin):
    list_display = ("id", "user_pickup_name", "phone_number", "scheduled_date", "estimated_weight", "created_at")
    list_filter = ("scheduled_date", "created_at")
    search_fields = ("user_pickup_name", "phone_number", "address", "message")
    readonly_fields = ("created_at", "updated_at")
    fieldsets = (
        ("Pickup Information", {"fields": ("pickup", "driver_details")}),
        (
            "Stored Details",
            {
                "fields": (
                    "user_pickup_name",
                    "phone_number",
                    "scheduled_date",
                    "scheduled_time",
                    "estimated_weight",
                    "address",
                )
            },
        ),
        ("Report", {"fields": ("message",)}),
        ("Timestamps", {"fields": ("created_at", "updated_at"), "classes": ("collapse",)}),
    )


class BillItemInline(admin.TabularInline):
    model = BillItem
    extra = 0
    readonly_fields = ("product_id", "product_name", "price", "quantity", "total")


@admin.register(Bill)
class BillAdmin(admin.ModelAdmin):
    list_display = ("id", "user_name", "driver_name", "grand_total", "created_at")
    list_filter = ("pickup_date", "created_at")
    search_fields = ("user_name", "driver_name", "user_phone")
    readonly_fields = ("created_at", "updated_at")
    inlines = [BillItemInline]
    fieldsets = (
        ("Pickup Information", {"fields": ("pickup", "driver_details")}),
        ("User Details", {"fields": ("user_name", "user_phone", "user_address")}),
        ("Pickup Schedule", {"fields": ("pickup_date", "pickup_time")}),
        ("Driver Details", {"fields": ("driver_name", "driver_phone")}),
        ("Bill", {"fields": ("grand_total",)}),
        ("Timestamps", {"fields": ("created_at", "updated_at"), "classes": ("collapse",)}),
    )
