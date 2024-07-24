from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model

class Command(BaseCommand):
    """
    This Django management command creates a superuser with specified credentials if one does not already exist.
    """

    help = 'Creates a superuser with specified credentials if one does not already exist.'

    def add_arguments(self, parser):
        """
        Adds command line arguments to the command.
        --username: Username for the superuser (default: 'Admin')
        --email: Email for the superuser (default: 'pedram.9060@gmail.com')
        --password: Password for the superuser (default: 'qwertyQ@1')
        --phone_number: Phone number for the superuser (default: '09128355747')
        """
        parser.add_argument('--username', type=str, default='Admin', help='Username for the superuser')
        parser.add_argument('--email', type=str, default='pedram.9060@gmail.com', help='Email for the superuser')
        parser.add_argument('--password', type=str, default='qwertyQ@1', help='Password for the superuser')
        parser.add_argument('--phone_number', type=str, default='09128355747', help='Phone number for the superuser')

    def handle(self, *args, **options):
        """
        Handles the command execution.
        Checks if a user with the specified username exists.
        If not, creates a new superuser with the provided credentials.
        If the user already exists, outputs a warning message.
        """
        User = get_user_model()
        username = options['username']
        email = options['email']
        password = options['password']
        phone_number = options['phone_number']

        if not User.objects.filter(username=username).exists():
            User.objects.create_superuser(username=username, email=email, password=password, phone_number=phone_number)
            self.stdout.write(self.style.SUCCESS(f'Superuser {username} created successfully'))
        else:
            self.stdout.write(self.style.WARNING(f'Superuser {username} already exists'))
