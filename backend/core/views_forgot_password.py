from django.contrib.auth import get_user_model
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny   # <-- add this

User = get_user_model()

class ForgotPasswordView(APIView):
    """
    Simple 'forgot password' endpoint:
    client sends username + new_password + confirm_password.
    No email, no OTP.
    """
    permission_classes = [AllowAny]   # <-- make endpoint public

    def post(self, request):
        username = request.data.get("username", "").strip()
        new_password = request.data.get("new_password", "")
        confirm_password = request.data.get("confirm_password", "")

        if not username or not new_password or not confirm_password:
            return Response(
                {"detail": "All fields are required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if new_password != confirm_password:
            return Response(
                {"detail": "Passwords do not match."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            user = User.objects.get(username=username)
        except User.DoesNotExist:
            return Response(
                {"detail": "User not found."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        user.set_password(new_password)
        user.save()

        return Response(
            {"detail": "Password reset successfully."},
            status=status.HTTP_200_OK,
        )
