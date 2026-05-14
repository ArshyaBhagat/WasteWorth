# Generated migration to add driver_details field and accepted status

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0010_pickup_address'),
    ]

    operations = [
        migrations.AlterField(
            model_name='pickup',
            name='status',
            field=models.CharField(
                choices=[
                    ('scheduled', 'Scheduled'),
                    ('accepted', 'Accepted'),
                    ('completed', 'Completed'),
                    ('cancelled', 'Cancelled'),
                ],
                default='scheduled',
                max_length=20
            ),
        ),
        migrations.AddField(
            model_name='pickup',
            name='driver_details',
            field=models.ForeignKey(
                blank=True,
                null=True,
                on_delete=django.db.models.deletion.SET_NULL,
                related_name='pickups',
                to='core.driverdetails'
            ),
        ),
    ]
