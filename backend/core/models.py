from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    ROLE_CHOICES = (
        ("user", "User"),
        ("driver", "Driver"),
        ("admin", "Admin"),
    )

    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default="user")
    phone_number = models.CharField(max_length=15, blank=True, null=True)
    address = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"{self.username} ({self.role})"


class Pickup(models.Model):
    STATUS_CHOICES = (
        ("scheduled", "Scheduled"),
        ("accepted", "Accepted"),
        ("completed", "Completed"),
        ("cancelled", "Cancelled"),
    )

    # ✅ Manpower choices (store backend values, show clean label)
    MANPOWER_CHOICES = (
        ("less than four", "Less than four"),
        ("more than four", "More than four"),
    )

    # ✅ Time-slot choices (store hyphen values, show formatted label)
    TIME_SLOT_CHOICES = (
        ("10-2pm", "10:00 AM - 2:00 PM"),
        ("5-8pm", "5:00 PM - 8:00 PM"),
    )

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="pickups")
    driver_details = models.ForeignKey(
        "DriverDetails",
        on_delete=models.SET_NULL,
        related_name="pickups",
        blank=True,
        null=True,
    )

    # ✅ restricted to MANPOWER_CHOICES
    manpower = models.CharField(max_length=50, choices=MANPOWER_CHOICES)

    date = models.DateField()

    # ✅ restricted to TIME_SLOT_CHOICES
    time_slot = models.CharField(max_length=20, choices=TIME_SLOT_CHOICES)

    weight = models.CharField(max_length=50)
    address = models.TextField(blank=True, null=True)

    # ✅ use callable, not default=list()
    categories = models.JSONField(default=list)

    # ✅ Photo field (Flutter multipart key must be "photo")
    photo = models.ImageField(upload_to="pickup_photos/", blank=True, null=True)

    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default="scheduled")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"Pickup #{self.id} - {self.user.username} ({self.status})"


class Product(models.Model):
    CATEGORY_CHOICES = (
        ("IT Waste", "IT Waste"),
        ("Vehicle Scrap", "Vehicle Scrap"),
        ("Household Scrap", "Household Scrap"),
        ("Metal Scrap", "Metal Scrap"),
        ("Plastic & Paper", "Plastic & Paper"),
        ("E-Waste", "E-Waste"),
        ("Appliance Scrap", "Appliance Scrap"),
        ("Furniture Scrap", "Furniture Scrap"),
        ("Glass Scrap", "Glass Scrap"),
        ("Miscellaneous", "Miscellaneous"),
    )

    product_name = models.CharField(max_length=100)
    product_description = models.CharField(max_length=200, blank=True, null=True)
    product_price = models.CharField(max_length=50)
    product_category = models.CharField(max_length=100, choices=CATEGORY_CHOICES)
    product_icon = models.CharField(max_length=10, default="📦")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["product_category", "product_name"]

    def __str__(self):
        return f"{self.product_name} - {self.product_category}"


class DriverDetails(models.Model):
    STATUS_CHOICES = (
        ("online", "Online"),
        ("offline", "Offline"),
    )

    user = models.OneToOneField(
        User, on_delete=models.CASCADE, related_name="driver_details"
    )
    driver_name = models.CharField(max_length=100)
    phone_number = models.CharField(max_length=15)
    email_id = models.EmailField()
    address = models.TextField()
    vehicle_name = models.CharField(max_length=100)
    vehicle_number = models.CharField(max_length=50, unique=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default="offline")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.driver_name} - {self.vehicle_number} ({self.status})"


class Report(models.Model):
    pickup = models.ForeignKey(Pickup, on_delete=models.CASCADE, related_name="reports")
    driver_details = models.ForeignKey(
        DriverDetails, on_delete=models.CASCADE, related_name="reports"
    )

    user_pickup_name = models.CharField(max_length=255, blank=True, null=True)
    phone_number = models.CharField(max_length=15, blank=True, null=True)
    scheduled_date = models.DateField(blank=True, null=True)
    scheduled_time = models.CharField(max_length=50, blank=True, null=True)
    estimated_weight = models.CharField(max_length=100, blank=True, null=True)
    address = models.TextField(blank=True, null=True)
    message = models.TextField()

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"Report for Pickup #{self.pickup.id} by {self.driver_details.driver_name}"


class Bill(models.Model):
    pickup = models.OneToOneField(Pickup, on_delete=models.CASCADE, related_name="bill")
    driver_details = models.ForeignKey(
        DriverDetails, on_delete=models.CASCADE, related_name="bills"
    )

    user_name = models.CharField(max_length=255)
    user_phone = models.CharField(max_length=15)
    user_address = models.TextField()
    pickup_date = models.DateField()
    pickup_time = models.CharField(max_length=50)
    driver_name = models.CharField(max_length=100)
    driver_phone = models.CharField(max_length=15)

    grand_total = models.DecimalField(max_digits=10, decimal_places=2)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"Bill for Pickup #{self.pickup.id} - ₹{self.grand_total}"


class BillItem(models.Model):
    bill = models.ForeignKey(Bill, on_delete=models.CASCADE, related_name="items")
    product_id = models.IntegerField()
    product_name = models.CharField(max_length=255)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    quantity = models.IntegerField()
    total = models.DecimalField(max_digits=10, decimal_places=2)

    def __str__(self):
        return f"{self.product_name} x {self.quantity}"
