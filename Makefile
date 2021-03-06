all: report

OUT_DIR=./out/
CONF_DIR=./conf
TESTS_DIR=./tests
RUNNERS_DIR=./tools/runners
THIRD_PARTY_DIR=./third_party
GENERATORS_DIR=./generators

export OUT_DIR
export CONF_DIR
export THIRD_PARTY_DIR
export TESTS_DIR
export RUNNERS_DIR
export GENERATORS_DIR

include tools/runners.mk

.PHONY: clean init info tests generate-tests report

clean:
	rm -rf $(OUT_DIR)
	rm -rf $(TESTS_DIR)/generated/

init:
ifneq (,$(wildcard $(OUT_DIR)/*))
	@echo -e "!!! WARNING !!!\nThe output directory is not empty\n"
endif

runners:

# $(1) - runner name
# $(2) - test
define runner_gen
$(OUT_DIR)/logs/$(1)/$(2).log: $(TESTS_DIR)/$(2)
	./tools/runner --runner $(1) --test $(2) --out $(OUT_DIR)/logs/$(1)/$(2).log --quiet

tests: $(OUT_DIR)/logs/$(1)/$(2).log
endef

define generator_gen
generate-$(1):
	$(GENERATORS_DIR)/$(1) $(1)

generate-tests: generate-$(1)
endef

RUNNERS_FOUND := $(wildcard $(RUNNERS_DIR)/*.py)
RUNNERS_FOUND := $(RUNNERS_FOUND:$(RUNNERS_DIR)/%=%)
RUNNERS_FOUND := $(basename $(RUNNERS_FOUND))
RUNNERS := $(shell OUT_DIR=$(OUT_DIR) ./tools/check-runners $(RUNNERS_FOUND))
TESTS := $(shell find $(TESTS_DIR) -type f -iname *.sv)
TESTS := $(TESTS:$(TESTS_DIR)/%=%)
GENERATORS := $(wildcard $(GENERATORS_DIR)/*)
GENERATORS := $(GENERATORS:$(GENERATORS_DIR)/%=%)

space := $(subst ,, )

ifneq ($(USE_ALL_RUNNERS),)
ifneq ($(RUNNERS), $(RUNNERS_FOUND))
$(warning Runners found: $(RUNNERS))
$(warning Runners defined: $(RUNNERS_FOUND))
$(error Some runners are missing)
endif
endif

info:
	@echo -e "Found the following runners:$(subst $(space),"\\n \* ", $(RUNNERS))\n"

PY_FILES := $(shell file generators/* tools/* | sed -ne 's/:.*python.*//pI')
PY_FILES += $(wildcard tools/*.py)
PY_FILES += $(wildcard tools/runners/*.py)

format:
	python3 -m yapf -p -i $(PY_FILES)

tests:

generate-tests:

report: init tests
	./tools/sv-report --revision $(shell git rev-parse --short HEAD)
	cp $(CONF_DIR)/report/*.css $(OUT_DIR)/report/
	cp $(CONF_DIR)/report/*.js $(OUT_DIR)/report/

$(foreach g, $(GENERATORS), $(eval $(call generator_gen,$(g))))
$(foreach r, $(RUNNERS),$(foreach t, $(TESTS),$(eval $(call runner_gen,$(r),$(t)))))
