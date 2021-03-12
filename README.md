# Temple

VIP Boxing Club.

The project contains the rails application for managing users of Temple.

## Installation

The project is built on top of Rails 4.2.

### Prerequisites

* Ruby **2.3.7**
* Redis
* PostgreSQL
* ImageMagick
* NodeJS
* wkhtmltopdf (>= 0.12)

### First install
  * Install NodeJS
  * Install npm
  * Install Homebrew
  * ```brew install postgresql```
  * ```brew install rbenv```
  * ```brew install imagemagick```
  * ```brew install wkhtmltopdf```
  * ```brew install xml2```
  * ```brew install v8-315```
  * ```npm install bower```

### Configuring

    git clone git@github.com:novagile/temple.git
    cd temple
    bundle config build.nokogiri --use-system-libraries --with-xml2-include=/usr/local/opt/libxml2/include/libxml2
    bundle config build.therubyracer --with-v8-dir=/usr/local/opt/v8-315
    bundle config build.libv8 --with-v8-dir=/usr/local/opt/v8-315
    gem install therubyracer --
    bundle install
    https://github.com/teampoltergeist/poltergeist # Installing PhantomJS section
    ssh web@.....
      cd /srv/temple_staging
      pg_dump -U web -Fc temple_staging > tsc_temple_staging_utf8.dump
    scp web@.....:/home/web/temple_staging_utf8.sql .
    bundle exec rake db:drop:all db:create:all
    pg_restore --clean --if-exists --no-acl --no-owner --verbose -d temple_dev -U postgres --disable-triggers --single-transaction tsc_temple_staging_utf8.dump
    foreman start

## Test suite

    ```bundle exec rake```

    or ```guard``` Then press Enter


When running the test suite a test coverage report is generated at ./coverage/index.html

## Documentation

Documentation of **all** public methods and external classes is **mandatory**.
Please refer to http://tomdoc.org/ for the specifications.

## API

**Domains** :

  - Staging: `http://templestg.appliz.com`

### Card scans

#### Request

**URI** : `/card_scans`

**method** : `POST`

**Headers**

- `X-Auth` : the authentication token hash, `string`

**Body**

The servers expects a JSON payload in the request's body, with the following attributes set :

  - `card_reference` : the card's unique indentifier, `string`
  - `scan_point` : the scanner's id on which the card was scanned, `integer`
  - `scanned_at` : datetime of the scan, `string` ISO 8601 compliant (ex: `'2014-02-02T14:50:30+02:00'`)
  - `accepted` : whether the scan was accepted or not, `boolean`

#### Response

##### Successful record creation

If the request succeeds and the record is created, the response returns the values of the record's attributes.

**HTTP Code** : `201`

**Body example** :

    {
      card_reference: "abdcd",
      scan_point: 2,
      scanned_at: "2014-03-03T18:48:19+01:00",
      accepted: true
    }

##### Unsuccessful record creation

If the request succeeds but the record is not created, the reponse returns a hash of errors.

**HTTP Code** : `400`

**Body example** :

    {
      errors: {
        accepted: "doit être renseigné ",
        scanned_at: "doit être renseigné ",
        scan_point: "doit être renseigné ",
        user: "doit être renseigné "
      }
    }

##### Card reference not found

If the given card reference can not be found, the response returns a 404 Not Found HTTP error, with an empty body.

**HTTP Code** : `404`

**Body** : Empty
