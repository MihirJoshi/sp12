# contrib/pg_trgm/Makefile

MODULE_big = pg_trgm
OBJS = trgm_op.o

EXTENSION = pg_trgm
DATA = pg_trgm--1.0.sql pg_trgm--unpackaged--1.0.sql

REGRESS = pg_trgm

ifdef USE_PGXS
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
else
subdir = contrib/pg_trgm
top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
endif
