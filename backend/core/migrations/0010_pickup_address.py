# Generated migration to add address field to Pickup model

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0009_driverdetails'),
    ]

    operations = [
        migrations.AddField(
            model_name='pickup',
            name='address',
            field=models.TextField(blank=True, null=True),
        ),
    ]
