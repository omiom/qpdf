# --- Required interface definitions ---

OBJ=o
LOBJ=lo

# Usage: $(call libname,base)
define libname
lib$(1).la
endef

# Usage: $(call binname,base)
define binname
$(1)
endef

# --- Private definitions ---

# Usage: $(call libdepflags,$(basename obj))
# Usage: $(call fixdeps,$(basename obj))
ifeq ($(GENDEPS),1)
libdepflags=-MD -MF $(1).tdep -MP
fixdeps=sed -e 's/\.o:/.lo:/' < $(1).tdep > $(1).dep

else
libdepflags=
fixdeps=
endif

# --- Required rule definitions ---

#                       1   2
# Usage: $(call compile,src,includes)
define compile
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) \
		$(call depflags,$(basename $(call src_to_obj,$(1)))) \
		$(foreach I,$(2),-I$(I)) \
		-c $(1) -o $(call src_to_obj,$(1))
endef

#                       1   2
# Usage: $(call c_compile,src,includes)
define c_compile
	$(CC) $(CPPFLAGS) $(CFLAGS) \
		$(call depflags,$(basename $(call src_to_obj,$(1)))) \
		$(foreach I,$(2),-I$(I)) \
		-c $(1) -o $(call c_src_to_obj,$(1))
endef

#                          1   2
# Usage: $(call libcompile,src,includes)
define libcompile
	$(LIBTOOL) --quiet --mode=compile \
		$(CXX) $(CPPFLAGS) $(CXXFLAGS) \
		$(call libdepflags,$(basename $(call src_to_obj,$(1)))) \
		$(foreach I,$(2),-I$(I)) \
		-c $(1) -o $(call src_to_obj,$(1)); \
	$(call fixdeps,$(basename $(call src_to_obj,$(1))))
endef

#                        1    2
# Usage: $(call makeslib,objs,library)
define makeslib
	$(RM) $2
	ar cru $(2) $(1)
	ranlib $(2)
endef

#                       1    2       3       4        5
# Usage: $(call makelib,objs,library,current,revision,age)
define makelib
	$(LIBTOOL) --mode=link \
		$(CXX) $(CXXFLAGS) -o $(2) $(1) $(LDFLAGS) $(LIBS) \
		 -rpath $(libdir) -version-info $(3):$(4):$(5)
endef

#                       1    2
# Usage: $(call makebin,objs,binary)
define makebin
	$(LIBTOOL) --mode=link \
		$(CXX) $(CXXFLAGS) $(1) -o $(2) $(LDFLAGS) \
		-Llibqpdf/$(OUTPUT_DIR) -lqpdf $(LIBS)
endef