#!/bin/sh
## startup script

if [ "$DATABASE" = "postgres" ]
then
echo "Waiting for postgres..."
while ! nc -z $SQL_HOST $SQL_PORT; do
sleep 0.1
done
echo "PostgreSQL started"
fi

# clear database
# python manage.py flush --no-input # only uncomment to clear the database!
# make migrations
cd /src
python manage.py makemigrations --no-input;
python manage.py makemigrations stock_control --no-input;  # ensure app migrations have happened
python manage.py makemigrations accounts --no-input;  # ensure app migrations have happened
# migrate
python manage.py migrate --no-input;
# collect static
python manage.py collectstatic --no-input
# run django_q
python manage.py qcluster &
# run server
#gunicorn spm_api.wsgi:application --name=SimplePhotoManagement --bind 0.0.0.0:8000 --config /config/gunicorn.py --error-logfile /var/log/gunicorn/errors.log
python manage.py runserver 0.0.0.0:8000;  # comment out if using gunicorn
exec "$@"
