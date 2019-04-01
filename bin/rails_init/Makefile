service := 'rails'

.PHONY: bash install update generate test test-all console \
	create setup seed migrate migrate-reset rollback

bash:
	@docker-compose run --rm $(service) bash

install:
	@docker-compose run --rm $(service) bundle install
update:
	@docker-compose run --rm $(service) bundle update

generate:
ifeq ($(args),)
	$(error 'required args')
endif
	@docker-compose run --rm $(service) bundle exec rails generate $(args)
test:
	@docker-compose run --rm $(service) bundle exec rails test $(args)
test-all:
	@docker-compose run --rm $(service) bundle exec rails test
console:
	@docker-compose run --rm $(service) bundle exec rails console --sandbox

create:
	@docker-compose run --rm $(service) bundle exec rails db:create
setup:
	@docker-compose run --rm $(service) bundle exec rails db:setup
seed:
	@docker-compose run --rm $(service) bundle exec rails db:seed
migrate:
	@docker-compose run --rm $(service) bundle exec rails db:migrate
migrate-reset:
	@docker-compose run --rm $(service) bundle exec rails db:migrate:reset
rollback:
	@docker-compose run --rm $(service) bundle exec rails db:rollback
