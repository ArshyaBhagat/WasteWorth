from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404

from rest_framework import generics, status, serializers
from rest_framework.authtoken.models import Token
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Pickup, Product, DriverDetails, Report, Bill, BillItem
from .serializers import (
    RegisterSerializer,
    LoginSerializer,
    UserSerializer,
    PickupSerializer,
    ProductSerializer,
    DriverDetailsSerializer,
    ReportSerializer,
    BillSerializer,
)

User = get_user_model()


class RegisterView(generics.CreateAPIView):
    serializer_class = RegisterSerializer
    permission_classes = [AllowAny]

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()

        token, _ = Token.objects.get_or_create(user=user)

        return Response(
            {
                "user": UserSerializer(user).data,
                "token": token.key,
            },
            status=status.HTTP_201_CREATED,
        )


class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data["user"]

        token, _ = Token.objects.get_or_create(user=user)

        return Response(
            {
                "user": UserSerializer(user).data,
                "token": token.key,
            },
            status=status.HTTP_200_OK,
        )


class MeView(generics.RetrieveAPIView):
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        return self.request.user


class UpdateUserView(generics.UpdateAPIView):
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        return self.request.user

    def update(self, request, *args, **kwargs):
        user = self.get_object()
        serializer = self.get_serializer(user, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data, status=status.HTTP_200_OK)


# ✅ supports multipart/form-data for photo uploads (also works for normal JSON)
class CreatePickupView(generics.CreateAPIView):
    serializer_class = PickupSerializer
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class PickupListView(generics.ListAPIView):
    serializer_class = PickupSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Pickup.objects.filter(user=self.request.user)


class DriverPickupsListView(generics.ListAPIView):
    serializer_class = PickupSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        try:
            driver_details = DriverDetails.objects.get(user=self.request.user)
            return Pickup.objects.filter(driver_details=driver_details)
        except DriverDetails.DoesNotExist:
            return Pickup.objects.none()


class CancelPickupView(generics.UpdateAPIView):
    serializer_class = PickupSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = "pk"

    def get_queryset(self):
        # ✅ user can only ever cancel their own pickups
        return Pickup.objects.filter(user=self.request.user)

    def update(self, request, *args, **kwargs):
        pickup = self.get_object()

        # ✅ Prevent cancelling if already accepted/completed/cancelled
        if pickup.status != "scheduled":
            return Response(
                {"error": "Pickup cannot be cancelled at this stage."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        pickup.status = "cancelled"
        pickup.save()
        return Response(PickupSerializer(pickup).data, status=status.HTTP_200_OK)


class ProductListView(generics.ListAPIView):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer
    permission_classes = [AllowAny]


class CreateDriverDetailsView(generics.CreateAPIView):
    serializer_class = DriverDetailsSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class RetrieveDriverDetailsView(generics.RetrieveAPIView):
    serializer_class = DriverDetailsSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        return get_object_or_404(DriverDetails, user=self.request.user)


class UpdateDriverDetailsView(generics.UpdateAPIView):
    serializer_class = DriverDetailsSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        return get_object_or_404(DriverDetails, user=self.request.user)


class DriverDetailsListView(generics.ListAPIView):
    queryset = DriverDetails.objects.all()
    serializer_class = DriverDetailsSerializer
    permission_classes = [AllowAny]


class AvailablePickupsView(generics.ListAPIView):
    serializer_class = PickupSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Pickup.objects.filter(status="scheduled").order_by("-created_at")


class AcceptPickupView(generics.UpdateAPIView):
    serializer_class = PickupSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = "pk"

    def get_queryset(self):
        # ✅ Only scheduled pickups are eligible for accept
        return Pickup.objects.filter(status="scheduled")

    def update(self, request, *args, **kwargs):
        pickup = self.get_object()

        try:
            driver_details = DriverDetails.objects.get(user=request.user)
        except DriverDetails.DoesNotExist:
            return Response(
                {"error": "Driver details not found. Please complete your driver profile."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Extra safety: ensure pickup still scheduled
        if pickup.status != "scheduled":
            return Response(
                {"error": "This pickup is no longer available."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        pickup.status = "accepted"
        pickup.driver_details = driver_details
        pickup.save()
        return Response(PickupSerializer(pickup).data, status=status.HTTP_200_OK)


class ReportCreateView(generics.CreateAPIView):
    serializer_class = ReportSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        try:
            driver_details = DriverDetails.objects.get(user=self.request.user)
            pickup = serializer.validated_data.get("pickup")

            serializer.save(
                driver_details=driver_details,
                user_pickup_name=pickup.user.username,
                phone_number=pickup.user.phone_number or "",
                scheduled_date=pickup.date,
                scheduled_time=pickup.get_time_slot_display(),
                estimated_weight=pickup.weight,
                address=pickup.address or "",
            )
        except DriverDetails.DoesNotExist:
            raise serializers.ValidationError("Driver details not found.")


class DriverReportsListView(generics.ListAPIView):
    serializer_class = ReportSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        try:
            driver_details = DriverDetails.objects.get(user=self.request.user)
            return Report.objects.filter(driver_details=driver_details)
        except DriverDetails.DoesNotExist:
            return Report.objects.none()


class BillCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            driver_details = DriverDetails.objects.get(user=request.user)

            pickup_id = request.data.get("pickup")
            items_data = request.data.get("items", [])
            grand_total = request.data.get("grand_total")

            if not pickup_id:
                return Response(
                    {"error": "Pickup ID is required."},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            if not items_data:
                return Response(
                    {"error": "Bill items are required."},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            if grand_total is None:
                return Response(
                    {"error": "Grand total is required."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            pickup = Pickup.objects.get(id=pickup_id)

            # ✅ Optional safety: only the assigned driver can bill that pickup
            if pickup.driver_details_id != driver_details.id:
                return Response(
                    {"error": "You are not assigned to this pickup."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            # ✅ Optional safety: only accepted pickups should be completed/billed
            if pickup.status != "accepted":
                return Response(
                    {"error": "Only accepted pickups can be completed."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            bill = Bill.objects.create(
                pickup=pickup,
                driver_details=driver_details,
                user_name=pickup.user.username,
                user_phone=pickup.user.phone_number or "",
                user_address=pickup.address or "",
                pickup_date=pickup.date,
                pickup_time=pickup.get_time_slot_display(),
                driver_name=driver_details.driver_name,
                driver_phone=driver_details.phone_number,
                grand_total=grand_total,
            )

            for item in items_data:
                BillItem.objects.create(
                    bill=bill,
                    product_id=item.get("product_id"),
                    product_name=item.get("product_name"),
                    price=item.get("price"),
                    quantity=item.get("quantity"),
                    total=item.get("total"),
                )

            pickup.status = "completed"
            pickup.save()

            return Response(BillSerializer(bill).data, status=status.HTTP_201_CREATED)

        except DriverDetails.DoesNotExist:
            return Response(
                {"error": "Driver details not found."},
                status=status.HTTP_400_BAD_REQUEST,
            )
        except Pickup.DoesNotExist:
            return Response(
                {"error": "Pickup not found."},
                status=status.HTTP_400_BAD_REQUEST,
            )
        except Exception as e:
            import traceback
            traceback.print_exc()
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class DriverBillsListView(generics.ListAPIView):
    serializer_class = BillSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        try:
            driver_details = DriverDetails.objects.get(user=self.request.user)
            return Bill.objects.filter(driver_details=driver_details)
        except DriverDetails.DoesNotExist:
            return Bill.objects.none()


class UserBillsListView(generics.ListAPIView):
    serializer_class = BillSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Bill.objects.filter(pickup__user=self.request.user)
