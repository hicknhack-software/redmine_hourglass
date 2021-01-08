FROM redmine:4.1.1

RUN apt-get update && apt-get install -y build-essential libffi-dev
RUN rm /usr/src/redmine/Gemfile.lock.mysql2
RUN touch /usr/src/redmine/Gemfile.lock.mysql2
