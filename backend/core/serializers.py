import json

from django.contrib.auth import authenticate, get_user_model
from rest_framework import serializers

from .models import Pickup, Product, DriverDetails, Report, Bill, BillItem

User = get_user_model()


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=6)

    class Meta:
        model = User
        fields = ["id", "username", "email", "password", "phone_number"]
        extra_kwargs = {"email": {"required": True}}

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data["username"],
            email=validated_data["email"],
            password=validated_data["password"],
            phone_number=validated_data.get("phone_number", ""),
            role="user",
        )
        return user


class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)

    def validate(self, attrs):
        username = attrs.get("username")
        password = attrs.get("password")
        user = authenticate(username=username, password=password)
        if not user:
            raise serializers.ValidationError("Invalid credentials.")
        attrs["user"] = user
        return attrs


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["id", "username", "email", "role", "phone_number", "address"]


class DriverDetailsSerializer(serializers.ModelSerializer):
    class Meta:
        model = DriverDetails
        fields = [
            "id",
            "user",
            "driver_name",
            "phone_number",
            "email_id",
            "address",
            "vehicle_name",
            "vehicle_number",
            "status",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "user", "created_at", "updated_at"]


class PickupSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    driver_details = DriverDetailsSerializer(read_only=True)

    # ✅ Human-readable label from Django choices
    time_slot_display = serializers.CharField(
        source="get_time_slot_display", read_only=True
    )

    # ✅ NEW: Human-readable label for manpower choices
    manpower_display = serializers.CharField(
        source="get_manpower_display", read_only=True
    )

    class Meta:
        model = Pickup
        fields = [
            "id",
            "user",
            "driver_details",
            "manpower",           # stored value
            "manpower_display",   # label
            "date",
            "time_slot",          # stored value: "10-2pm" / "5-8pm"
            "time_slot_display",  # label: "10:00 AM - 2:00 PM" / "5:00 PM - 8:00 PM"
            "weight",
            "address",
            "categories",
            "photo",
            "status",
            "created_at",
        ]
        read_only_fields = [
            "id",
            "user",
            "driver_details",
            "status",
            "created_at",
            "time_slot_display",
            "manpower_display",
        ]

    def validate_categories(self, value):
        """
        Supports:
        - JSON request: categories = ["Paper", "Metals"]
        - multipart/form-data: categories = '["Paper","Metals"]' (string)
        """
        if isinstance(value, str):
            try:
                value = json.loads(value)
            except Exception:
                raise serializers.ValidationError("Invalid categories JSON string.")

        if not isinstance(value, list):
            raise serializers.ValidationError("Categories must be a list.")

        return value

    # Optional: DRF usually handles ImageField fine, but keeping is OK.
    def create(self, validated_data):
        photo = validated_data.pop("photo", None)
        pickup = Pickup.objects.create(**validated_data)
        if photo:
            pickup.photo = photo
            pickup.save()
        return pickup


class ProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = [
            "id",
            "product_name",
            "product_description",
            "product_price",
            "product_category",
            "product_icon",
            "created_at",
        ]
        read_only_fields = ["id", "created_at"]


class ReportSerializer(serializers.ModelSerializer):
    class Meta:
        model = Report
        fields = [
            "id",
            "pickup",
            "driver_details",
            "user_pickup_name",
            "phone_number",
            "scheduled_date",
            "scheduled_time",
            "estimated_weight",
            "address",
            "message",
            "created_at",
            "updated_at",
        ]
        read_only_fields = [
            "id",
            "driver_details",
            "user_pickup_name",
            "phone_number",
            "scheduled_date",
            "scheduled_time",
            "estimated_weight",
            "address",
            "created_at",
            "updated_at",
        ]


class BillItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = BillItem
        fields = ["id", "product_id", "product_name", "price", "quantity", "total"]


class BillSerializer(serializers.ModelSerializer):
    items = BillItemSerializer(many=True, read_only=True)
    pickup_details = serializers.SerializerMethodField()

    class Meta:
        model = Bill
        fields = [
            "id",
            "pickup",
            "driver_details",
            "user_name",
            "user_phone",
            "user_address",
            "pickup_date",
            "pickup_time",
            "driver_name",
            "driver_phone",
            "grand_total",
            "items",
            "pickup_details",
            "created_at",
            "updated_at",
        ]
        read_only_fields = [
            "id",
            "driver_details",
            "user_name",
            "user_phone",
            "user_address",
            "pickup_date",
            "pickup_time",
            "driver_name",
            "driver_phone",
            "created_at",
            "updated_at",
        ]

    def get_pickup_details(self, obj):
        if obj.pickup:
            return {
                "weight": obj.pickup.weight,
                "manpower": obj.pickup.manpower,
                "manpower_display": obj.pickup.get_manpower_display()
                if hasattr(obj.pickup, "get_manpower_display")
                else obj.pickup.manpower,
                "categories": obj.pickup.categories,
                "photo": obj.pickup.photo.url if obj.pickup.photo else None,
            }
        return None
