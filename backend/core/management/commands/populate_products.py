from django.core.management.base import BaseCommand
from core.models import Product


class Command(BaseCommand):
    help = 'Populate the database with scrap items and their prices'

    def add_arguments(self, parser):
        parser.add_argument('--force', action='store_true', help='Force delete and recreate all products')

    def handle(self, *args, **options):
        products_data = [
            ('CPU', 'Processor units', '₹25/kg', 'IT Waste', '🧠'),
            ('Monitor', 'Desktop monitors', '₹30/kg', 'IT Waste', '🖥️'),
            ('Laptop', 'Laptop units', '₹45/kg', 'IT Waste', '💻'),
            ('Printer', 'Printing machines', '₹20/kg', 'IT Waste', '🖨️'),
            ('Bike', 'Motorcycle scrap', '₹3200/unit', 'Vehicle Scrap', '🏍️'),
            ('Scooter', 'Scooter scrap', '₹2700/unit', 'Vehicle Scrap', '🛵'),
            ('Car', 'Automobile scrap', '₹18000/unit', 'Vehicle Scrap', '🚗'),
            ('Plastic', 'Household plastic items', '₹12/kg', 'Household Scrap', '🧴'),
            ('Paper', 'Newspaper & paper', '₹14/kg', 'Household Scrap', '📄'),
            ('Carton', 'Cardboard cartons', '₹10/kg', 'Household Scrap', '📦'),
            ('Iron', 'Iron metal scrap', '₹32/kg', 'Metal Scrap', '🔧'),
            ('Steel', 'Steel material', '₹40/kg', 'Metal Scrap', '🪨'),
            ('Aluminum', 'Aluminum scrap', '₹120/kg', 'Metal Scrap', '🥫'),
            ('Copper', 'Copper wires', '₹520/kg', 'Metal Scrap', '🔌'),
            ('Brass', 'Brass items', '₹380/kg', 'Metal Scrap', '🟡'),
            ('Mobile Phone', 'Old mobile phones', '₹150/unit', 'E-Waste', '📱'),
            ('Charger', 'Mobile chargers', '₹30/unit', 'E-Waste', '🔌'),
            ('Battery', 'Electronic batteries', '₹90/kg', 'E-Waste', '🔋'),
            ('Circuit Board', 'PCB boards', '₹650/kg', 'E-Waste', '🧩'),
            ('Wire / Cable', 'Electrical wires', '₹140/kg', 'E-Waste', '🪢'),
            ('Washing Machine', 'Old washing machines', '₹800/unit', 'Appliance Scrap', '🧺'),
            ('Refrigerator', 'Old refrigerators', '₹1200/unit', 'Appliance Scrap', '❄️'),
            ('Air Conditioner', 'AC units', '₹2500/unit', 'Appliance Scrap', '🌬️'),
            ('Microwave Oven', 'Microwave units', '₹600/unit', 'Appliance Scrap', '🍽️'),
            ('Newspaper', 'Old newspapers', '₹15/kg', 'Plastic & Paper', '📰'),
            ('Books', 'Old books', '₹12/kg', 'Plastic & Paper', '📘'),
            ('Office Paper', 'Office waste paper', '₹14/kg', 'Plastic & Paper', '🗂️'),
            ('Corrugated Cardboard', 'Cardboard boxes', '₹10/kg', 'Plastic & Paper', '📦'),
            ('Hard Plastic', 'Hard plastic items', '₹18/kg', 'Plastic & Paper', '🧱'),
            ('Soft Plastic', 'Soft plastic bags', '₹10/kg', 'Plastic & Paper', '🛍️'),
            ('PET Bottles', 'Plastic bottles', '₹22/kg', 'Plastic & Paper', '🍾'),
            ('Plastic Containers', 'Plastic containers', '₹14/kg', 'Plastic & Paper', '🧴'),
            ('Wooden Furniture', 'Old wooden furniture', '₹12/kg', 'Furniture Scrap', '🪵'),
            ('Iron Furniture', 'Metal furniture', '₹30/kg', 'Furniture Scrap', '🪑'),
            ('Plastic Furniture', 'Plastic furniture', '₹10/kg', 'Furniture Scrap', '🪑'),
            ('Glass Bottles', 'Glass bottles', '₹5/kg', 'Glass Scrap', '🍾'),
            ('Window Glass', 'Window glass', '₹6/kg', 'Glass Scrap', '🪟'),
            ('Broken Glass', 'Broken glass pieces', '₹3/kg', 'Glass Scrap', '💥'),
            ('Clothes', 'Old clothes & fabric', '₹6/kg', 'Miscellaneous', '👕'),
            ('Shoes', 'Old footwear', '₹5/kg', 'Miscellaneous', '👟'),
            ('Rubber', 'Rubber waste', '₹14/kg', 'Miscellaneous', '🛞'),
        ]

        if options['force']:
            Product.objects.all().delete()
            self.stdout.write(self.style.WARNING('Deleted all existing products'))

        for product_name, product_description, product_price, product_category, product_icon in products_data:
            product, created = Product.objects.get_or_create(
                product_name=product_name,
                product_category=product_category,
                defaults={'product_price': product_price, 'product_icon': product_icon, 'product_description': product_description}
            )
            if created:
                self.stdout.write(self.style.SUCCESS(f'Created {product_name}'))
            else:
                if options['force']:
                    self.stdout.write(f'{product_name} already exists (should not happen)')
                else:
                    self.stdout.write(f'{product_name} already exists')

        self.stdout.write(self.style.SUCCESS('Successfully populated products'))
