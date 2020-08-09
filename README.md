# README

POSTMAN DOCS AND COLLECTION: https://documenter.getpostman.com/view/11207309/SzfDw4mb
(On the top right click "Run in Postman" to import the collection)

1 - Install Rbenv. https://github.com/rbenv/rbenv. Ruby version -> 2.7.0p0

2 - Install postgres. Then run the following commands to set up the postgres server on your machine:<br />
  sudo su<br />
  su - postgres<br />
  psql<br />
  create role avenida_challenge with createdb login password 'avenida_challenge';<br />
  exit psql with \q<br />
  sudo service postgresql start<br />

3 - Clone this repo then cd to the project's folder.

4 - Execute bundle command to install gems.

5 - Create database and run migrations with: bundle exec rake db:create db:migrate

6 - If you're going to test the API with the collection, seed the database with: bundle exec rake db:seed
