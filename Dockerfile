FROM rails:onbuild

ADD . /rails/ie-ccda-endpoint

WORKDIR /rails/ie-ccda-endpoint
RUN bundle install
RUN rake db:migrate

RUN chmod 755 /rails/ie-ccda-endpoint/rails-entrypoint.sh
ENTRYPOINT ["/rails/ie-ccda-endpoint/rails-entrypoint.sh"]

EXPOSE 3000
