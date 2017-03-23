# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: python.eclass
# @MAINTAINER:
# Arfrever Frehtes Taifersar Arahesis <Arfrever@Apache.Org>
# @BLURB: Eclass for Python packages
# @DESCRIPTION:
# The python eclass contains miscellaneous, useful functions for Python packages.

_PYTHON_ECLASS_INHERITED="1"

readarray -t _PYTHON_INHERITED_ECLASSES_FUNCTIONS_OUTPUTS <<< "$(
	INHERITED="${INHERITED}${INHERITED:+ }multilib toolchain-funcs" inherit multilib toolchain-funcs &> /dev/null
	get_libdir
	get_libname
	tc-getCPP
	tc-getCC
	tc-getCXX
	tc-getAR
)" 2> /dev/null
_PYTHON_MULTILIB_LIBDIR="${_PYTHON_INHERITED_ECLASSES_FUNCTIONS_OUTPUTS[0]}"
_PYTHON_MULTILIB_LIBNAME="${_PYTHON_INHERITED_ECLASSES_FUNCTIONS_OUTPUTS[1]}"
_PYTHON_TOOLCHAIN_FUNCS_CPP="${_PYTHON_INHERITED_ECLASSES_FUNCTIONS_OUTPUTS[2]}"
_PYTHON_TOOLCHAIN_FUNCS_CC="${_PYTHON_INHERITED_ECLASSES_FUNCTIONS_OUTPUTS[3]}"
_PYTHON_TOOLCHAIN_FUNCS_CXX="${_PYTHON_INHERITED_ECLASSES_FUNCTIONS_OUTPUTS[4]}"
_PYTHON_TOOLCHAIN_FUNCS_AR="${_PYTHON_INHERITED_ECLASSES_FUNCTIONS_OUTPUTS[5]}"
unset _PYTHON_INHERITED_ECLASSES_FUNCTIONS_OUTPUTS

if ! has "${EAPI:-0}" 0 1 2 3 4 4-python 5 5-progress; then
	die "API of python.eclass in EAPI=\"${EAPI}\" not established"
fi

# @ECLASS-VARIABLE: PYTHON_ECLASS_API
# @DESCRIPTION:
# Specification of API of python.eclass in given EAPI.

if [[ -z "$(declare -p PYTHON_ECLASS_API 2> /dev/null)" ]]; then
	PYTHON_ECLASS_API="0"
fi

case "${EAPI:-0}" in
	0|1|2|3)
		_PYTHON_ECLASS_SUPPORTED_APIS=(0)
		;;
	4|5)
		_PYTHON_ECLASS_SUPPORTED_APIS=(0 1)
		;;
	4-python|5-progress)
		_PYTHON_ECLASS_SUPPORTED_APIS=(0)
		;;
esac

if ! has "${PYTHON_ECLASS_API}" ${_PYTHON_ECLASS_SUPPORTED_APIS[@]}; then
	die "PYTHON_ECLASS_API=\"${PYTHON_ECLASS_API}\" not supported in EAPI=\"${EAPI}\""
fi

_CPYTHON2_GLOBALLY_SUPPORTED_ABIS=(2.7)
_CPYTHON3_GLOBALLY_SUPPORTED_ABIS=(3.4 3.5 3.6 3.7)
_JYTHON_GLOBALLY_SUPPORTED_ABIS=(2.7-jython)
_PYPY_GLOBALLY_SUPPORTED_ABIS=(2.7-pypy 3.3-pypy)
_PYTHON_GLOBALLY_SUPPORTED_ABIS=(${_CPYTHON2_GLOBALLY_SUPPORTED_ABIS[@]} ${_CPYTHON3_GLOBALLY_SUPPORTED_ABIS[@]} ${_JYTHON_GLOBALLY_SUPPORTED_ABIS[@]} ${_PYPY_GLOBALLY_SUPPORTED_ABIS[@]})
_PYTHON_GLOBALLY_SUPPORTED_ORDERED_ABIS=(${_JYTHON_GLOBALLY_SUPPORTED_ABIS[@]} ${_PYPY_GLOBALLY_SUPPORTED_ABIS[@]} ${_CPYTHON2_GLOBALLY_SUPPORTED_ABIS[@]} ${_CPYTHON3_GLOBALLY_SUPPORTED_ABIS[@]})
_PYTHON_GLOBALLY_NONDEFAULT_ABIS="3.[5-9]"

# ========================================================================================================================
# ================================================= HANDLING OF METADATA =================================================
# ========================================================================================================================

_PYTHON_ABI_PATTERN_REGEX="([[:alnum:]]|\.|-|\*|\[|\])+"

_python_check_python_abi_matching() {
	local pattern patterns patterns_list="0" PYTHON_ABI

	while (($#)); do
		case "$1" in
			--patterns-list)
				patterns_list="1"
				;;
			--)
				shift
				break
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				break
				;;
		esac
		shift
	done

	if [[ "$#" -ne 2 ]]; then
		die "${FUNCNAME}() requires 2 arguments"
	fi

	PYTHON_ABI="$1"

	if [[ "${patterns_list}" == "0" ]]; then
		pattern="$2"

		if [[ "${pattern}" == *"-cpython" ]]; then
			[[ "${PYTHON_ABI}" =~ ^[[:digit:]]+\.[[:digit:]]+$ && "${PYTHON_ABI}" == ${pattern%-cpython} ]]
		elif [[ "${pattern}" == *"-jython" ]]; then
			[[ "${PYTHON_ABI}" == ${pattern} ]]
		elif [[ "${pattern}" == *"-pypy" ]]; then
			[[ "${PYTHON_ABI}" == ${pattern} ]]
		# Deprecated syntax of Python ABIs patterns.
		elif has "${EAPI:-0}" 0 1 2 3 4 4-python 5 5-progress && [[ "${pattern}" == *"-pypy-*" ]]; then
			[[ "${PYTHON_ABI}" == ${pattern%-*} ]]
		else
			if [[ "${PYTHON_ABI}" =~ ^[[:digit:]]+\.[[:digit:]]+$ ]]; then
				[[ "${PYTHON_ABI}" == ${pattern} ]]
			elif [[ "${PYTHON_ABI}" =~ ^[[:digit:]]+\.[[:digit:]]+-jython$ ]]; then
				[[ "${PYTHON_ABI%-jython}" == ${pattern} ]]
			elif [[ "${PYTHON_ABI}" =~ ^[[:digit:]]+\.[[:digit:]]+-pypy$ ]]; then
				[[ "${PYTHON_ABI%-pypy}" == ${pattern} ]]
			else
				die "${FUNCNAME}(): Unrecognized Python ABI '${PYTHON_ABI}'"
			fi
		fi
	else
		patterns="${2// /$'\n'}"

		while read -r pattern; do
			if _python_check_python_abi_matching "${PYTHON_ABI}" "${pattern}"; then
				return 0
			fi
		done <<< "${patterns}"

		return 1
	fi
}

_python_implementation() {
	if [[ "${CATEGORY}/${PN}" =~ ^dev-lang/python$ ]]; then
		return 0
	elif [[ "${CATEGORY}/${PN}" =~ ^dev-lang/jython$ ]]; then
		return 0
	elif [[ "${CATEGORY}/${PN}" =~ ^dev-lang/pypy$ ]]; then
		return 0
	else
		return 1
	fi
}

# @ECLASS-VARIABLE: PYTHON_ABI_TYPE
# @DESCRIPTION:
# Specification of type of Python ABIs.
#
# Valid values:
#   single
#   multiple
#
# PYTHON_ABI_TYPE="single" variable supported in:
#   EAPI="5-progress"
#
# PYTHON_ABI_TYPE="multiple" variable supported in:
#   EAPI="0"
#   EAPI="1"
#   EAPI="2"
#   EAPI="3"
#   EAPI="4"
#   EAPI="4-python"
#   EAPI="5"
#   EAPI="5-progress"
#
# PYTHON_ABI_TYPE="single" variable enables generation of python_single_abi_* USE flags in:
#   EAPI="5-progress"
#
# PYTHON_ABI_TYPE="multiple" variable enables generation of python_abis_* USE flags in:
#   EAPI="4-python"
#   EAPI="5-progress"

if [[ -n "$(declare -p PYTHON_ABI_TYPE 2> /dev/null)" ]]; then
	if [[ ! "${PYTHON_ABI_TYPE}" =~ ^(single|multiple)$ ]]; then
		die "Invalid PYTHON_ABI_TYPE=\"${PYTHON_ABI_TYPE}\" variable"
	fi
	if has "${EAPI:-0}" 0 1 2 3 4 4-python 5 && [[ "${PYTHON_ABI_TYPE}" =~ ^(single)$ ]]; then
		eerror "Use EAPI=\"5-progress\" or newer for PYTHON_ABI_TYPE=\"${PYTHON_ABI_TYPE}\" variable."
		die "PYTHON_ABI_TYPE=\"${PYTHON_ABI_TYPE}\" variable not supported in EAPI=\"${EAPI}\""
	fi
	if [[ -n "${PYTHON_MULTIPLE_ABIS}" ]]; then
		die "PYTHON_MULTIPLE_ABIS variable is redundant with PYTHON_ABI_TYPE variable"
	fi
	if [[ -n "${SUPPORT_PYTHON_ABIS}" ]]; then
		die "SUPPORT_PYTHON_ABIS variable is redundant with PYTHON_ABI_TYPE variable"
	fi
fi

if ! { has "${EAPI:-0}" 0 1 2 3 || { has "${EAPI:-0}" 4 5 && has "${PYTHON_ECLASS_API}" 0; }; }; then
	if [[ -n "${SUPPORT_PYTHON_ABIS}" ]]; then
		eerror "Use PYTHON_ABI_TYPE=\"multiple\" variable instead of SUPPORT_PYTHON_ABIS variable."
		die "SUPPORT_PYTHON_ABIS variable is banned"
	fi
	if [[ -n "${RESTRICT_PYTHON_ABIS}" ]]; then
		eerror "Use PYTHON_RESTRICTED_ABIS variable instead of RESTRICT_PYTHON_ABIS variable."
		die "RESTRICT_PYTHON_ABIS variable is banned"
	fi
fi

if ! has "${EAPI:-0}" 0 1 2 3 4 4-python 5 5-progress; then
	if [[ -n "${PYTHON_MULTIPLE_ABIS}" ]]; then
		eerror "Use PYTHON_ABI_TYPE=\"multiple\" variable instead of PYTHON_MULTIPLE_ABIS variable."
		die "PYTHON_MULTIPLE_ABIS variable is banned"
	fi
fi

# @ECLASS-VARIABLE: PYTHON_MULTIPLE_ABIS
# @DESCRIPTION:
# Set this to indicate that current package supports installation for multiple Python ABIs.
# Deprecated in favor of PYTHON_ABI_TYPE="multiple".

# @ECLASS-VARIABLE: PYTHON_RESTRICTED_ABIS
# @DESCRIPTION:
# Space-separated list of Python ABIs patterns. Support for Python ABIs matching any Python ABIs
# patterns specified in this list is disabled.

# @ECLASS-VARIABLE: PYTHON_NONDEFAULT_ABIS
# @DESCRIPTION:
# Space-separated list of Python ABIs patterns. Automatic enabling of python_single_abi_* USE flags
# corresponding to Python ABIs matching any Python ABIs patterns specified in this list is disabled.
# This variable is ignored in ebuilds not setting PYTHON_ABI_TYPE="single" variable.

_python_abi_type() {
	local type

	if [[ "$#" -ne 1 ]]; then
		die "${FUNCNAME}() requires 1 argument"
	fi

	type="$1"

	if [[ "${type}" == "implicit_single" ]]; then
		[[ -z "${PYTHON_ABI_TYPE}" && -z "${PYTHON_MULTIPLE_ABIS}" && -z "${SUPPORT_PYTHON_ABIS}" ]]
	elif [[ "${type}" == "single" ]]; then
		[[ "${PYTHON_ABI_TYPE}" == "single" ]]
	elif [[ "${type}" == "multiple" ]]; then
		if has "${EAPI:-0}" 0 1 2 3 || { has "${EAPI:-0}" 4 5 && has "${PYTHON_ECLASS_API}" 0; }; then
			[[ "${PYTHON_ABI_TYPE}" == "multiple" || -n "${PYTHON_MULTIPLE_ABIS}" || -n "${SUPPORT_PYTHON_ABIS}" ]]
		else
			[[ "${PYTHON_ABI_TYPE}" == "multiple" || -n "${PYTHON_MULTIPLE_ABIS}" ]]
		fi
	else
		die "${FUNCNAME}(): Unrecognized argument \"${type}\""
	fi
}

_python_set_IUSE() {
	local i PYTHON_ABI USE_flags

	_PYTHON_LOCALLY_SUPPORTED_ABIS=()

	for PYTHON_ABI in "${_PYTHON_GLOBALLY_SUPPORTED_ABIS[@]}"; do
		if ! _python_check_python_abi_matching --patterns-list "${PYTHON_ABI}" "${PYTHON_RESTRICTED_ABIS}"; then
			_PYTHON_LOCALLY_SUPPORTED_ABIS+=("${PYTHON_ABI}")
			if _python_abi_type single; then
				USE_flags+="${USE_flags:+ }python_single_abi_${PYTHON_ABI}"
			else
				USE_flags+="${USE_flags:+ }python_abis_${PYTHON_ABI}"
			fi
		fi
	done

	if _python_abi_type single; then
		for ((i = $((${#_PYTHON_GLOBALLY_SUPPORTED_ORDERED_ABIS[@]} - 1)); i >= 0; i--)); do
			PYTHON_ABI="${_PYTHON_GLOBALLY_SUPPORTED_ORDERED_ABIS[${i}]}"
			if has "${PYTHON_ABI}" "${_PYTHON_LOCALLY_SUPPORTED_ABIS[@]}" && ! _python_check_python_abi_matching --patterns-list "${PYTHON_ABI}" "${_PYTHON_GLOBALLY_NONDEFAULT_ABIS} ${PYTHON_NONDEFAULT_ABIS}"; then
				USE_flags="${USE_flags/python_single_abi_${PYTHON_ABI}/+python_single_abi_${PYTHON_ABI}}"
				break
			fi
		done
	fi

	if ! has "${EAPI:-0}" 4 5; then
		IUSE="${USE_flags}"
	fi
}

if _python_abi_type single || { ! has "${EAPI:-0}" 0 1 2 3 && _python_abi_type multiple; }; then
	_python_set_IUSE
fi
unset -f _python_set_IUSE

# @ECLASS-VARIABLE: PYTHON_DEPEND
# @DESCRIPTION:
# Specification of build time and run time dependency on Python implementational packages.
#
# Old API:
#   EAPI="0"
#   EAPI="1"
#   EAPI="2"
#   EAPI="3"
#   EAPI="4" + PYTHON_ECLASS_API="0"
#   EAPI="5" + PYTHON_ECLASS_API="0"
#
# New API:
#   EAPI="4" + PYTHON_ECLASS_API="1"
#   EAPI="4-python"
#   EAPI="5" + PYTHON_ECLASS_API="1"
#   EAPI="5-progress"
#
# PYTHON_DEPEND in new API is a dependency string with <<>> markers.
# <<>> markers indicate atoms of Python implementational packages.
# <<>> markers can contain USE dependencies.
# <<>> markers must contain versions ranges in ebuilds not setting PYTHON_ABI_TYPE variable.
#
# Syntax in old API:
#   PYTHON_DEPEND:             [[!]USE_flag? ]<versions_range>
#
# Syntax of versions range:
#   versions_range:            <version_components_group>[ version_components_group]
#   version_components_group:  <major_version[:[minimal_version][:maximal_version]]>
#   major_version:             <2|3|*>
#   minimal_version:           <minimal_major_version.minimal_minor_version>
#   maximal_version:           <maximal_major_version.maximal_minor_version>

# @ECLASS-VARIABLE: PYTHON_BDEPEND
# @DESCRIPTION:
# Specification of build time dependency on Python implementational packages.
#
# Old API:
#   EAPI="0"
#   EAPI="1"
#   EAPI="2"
#   EAPI="3"
#   EAPI="4" + PYTHON_ECLASS_API="0"
#   EAPI="5" + PYTHON_ECLASS_API="0"
#
# New API:
#   EAPI="4" + PYTHON_ECLASS_API="1"
#   EAPI="4-python"
#   EAPI="5" + PYTHON_ECLASS_API="1"
#   EAPI="5-progress"
#
# PYTHON_BDEPEND in new API is a dependency string with <<>> markers.
# <<>> markers indicate atoms of Python implementational packages.
# <<>> markers can contain USE dependencies.
# <<>> markers must contain versions ranges in ebuilds not setting PYTHON_ABI_TYPE variable.
#
# Syntax in old API:
#   PYTHON_BDEPEND:            [[!]USE_flag? ]<versions_range>
#
# Syntax of versions range:
#   versions_range:            <version_components_group>[ version_components_group]
#   version_components_group:  <major_version[:[minimal_version][:maximal_version]]>
#   major_version:             <2|3|*>
#   minimal_version:           <minimal_major_version.minimal_minor_version>
#   maximal_version:           <maximal_major_version.maximal_minor_version>

_python_parse_versions_range() {
	local input_value input_variable major_version maximal_version minimal_version output_variable python_atoms=() python_all="0" python_maximal_version python_minimal_version python_versions=() python2="0" python2_maximal_version python2_minimal_version python3="0" python3_maximal_version python3_minimal_version version_components_group version_components_groups

	input_value="$1"
	input_variable="$2"
	output_variable="$3"

	version_components_group_regex="(2|3|\*)(:([[:digit:]]+\.[[:digit:]]+)?(:([[:digit:]]+\.[[:digit:]]+)?)?)?"
	version_components_groups="${input_value}"

	if [[ "${version_components_groups}" =~ ^${version_components_group_regex}(\ ${version_components_group_regex})?$ ]]; then
		if [[ "${version_components_groups}" =~ ("*".*" "|" *"|^2.*\ (2|\*)|^3.*\ (3|\*)) ]]; then
			die "Invalid syntax of ${input_variable}: Incorrectly specified groups of versions"
		fi

		version_components_groups="${version_components_groups// /$'\n'}"
		while read -r version_components_group; do
			major_version="${version_components_group:0:1}"
			minimal_version="${version_components_group:2}"
			minimal_version="${minimal_version%:*}"
			maximal_version="${version_components_group:$((3 + ${#minimal_version}))}"

			if [[ "${major_version}" =~ ^(2|3)$ ]]; then
				if [[ -n "${minimal_version}" && "${major_version}" != "${minimal_version:0:1}" ]]; then
					die "Invalid syntax of ${input_variable}: Minimal version '${minimal_version}' not in specified group of versions"
				fi
				if [[ -n "${maximal_version}" && "${major_version}" != "${maximal_version:0:1}" ]]; then
					die "Invalid syntax of ${input_variable}: Maximal version '${maximal_version}' not in specified group of versions"
				fi
			fi

			if [[ "${major_version}" == "2" ]]; then
				python2="1"
				python_versions=("${_CPYTHON2_GLOBALLY_SUPPORTED_ABIS[@]}")
				python2_minimal_version="${minimal_version}"
				python2_maximal_version="${maximal_version}"
			elif [[ "${major_version}" == "3" ]]; then
				python3="1"
				python_versions=("${_CPYTHON3_GLOBALLY_SUPPORTED_ABIS[@]}")
				python3_minimal_version="${minimal_version}"
				python3_maximal_version="${maximal_version}"
			else
				python_all="1"
				python_versions=("${_CPYTHON2_GLOBALLY_SUPPORTED_ABIS[@]}" "${_CPYTHON3_GLOBALLY_SUPPORTED_ABIS[@]}")
				python_minimal_version="${minimal_version}"
				python_maximal_version="${maximal_version}"
			fi

			if [[ -n "${minimal_version}" && "${minimal_version%.*}" -eq "${python_versions[0]%.*}" && "${minimal_version#*.}" -le "${python_versions[0]#*.}" ]]; then
				minimal_version=""
				python_minimal_version=""
				python2_minimal_version=""
				python3_minimal_version=""
			fi

			# Bash >=4.2:
			# if [[ -n "${maximal_version}" && "${maximal_version%.*}" -eq "${python_versions[-1]%.*}" && "${maximal_version#*.}" -ge "${python_versions[-1]#*.}" ]]; then
			if [[ -n "${maximal_version}" && "${maximal_version%.*}" -eq "${python_versions[${#python_versions[@]}-1]%.*}" && "${maximal_version#*.}" -ge "${python_versions[${#python_versions[@]}-1]#*.}" ]]; then
				maximal_version=""
				python_maximal_version=""
				python2_maximal_version=""
				python3_maximal_version=""
			fi

			if [[ -n "${minimal_version}" ]] && ! has "${minimal_version}" "${python_versions[@]}"; then
				die "Invalid syntax of ${input_variable}: Unrecognized minimal version '${minimal_version}'"
			fi
			if [[ -n "${maximal_version}" ]] && ! has "${maximal_version}" "${python_versions[@]}"; then
				die "Invalid syntax of ${input_variable}: Unrecognized maximal version '${maximal_version}'"
			fi

			if [[ -n "${minimal_version}" && -n "${maximal_version}" && "${minimal_version}" > "${maximal_version}" ]]; then
				die "Invalid syntax of ${input_variable}: Minimal version '${minimal_version}' greater than maximal version '${maximal_version}'"
			fi
		done <<< "${version_components_groups}"

		_append_accepted_versions_range() {
			local accepted_version="0" i
			for ((i = $((${#python_versions[@]} - 1)); i >= 0; i--)); do
				if [[ "${python_versions[${i}]}" == "${python_maximal_version}" ]]; then
					accepted_version="1"
				fi
				if [[ "${accepted_version}" == "1" ]]; then
					python_atoms+=("=dev-lang/python-${python_versions[${i}]}*")
				fi
				if [[ "${python_versions[${i}]}" == "${python_minimal_version}" ]]; then
					accepted_version="0"
				fi
			done
		}

		if [[ "${python_all}" == "1" ]]; then
			if [[ -z "${python_minimal_version}" && -z "${python_maximal_version}" ]]; then
				python_atoms+=("dev-lang/python")
			else
				python_versions=("${_CPYTHON2_GLOBALLY_SUPPORTED_ABIS[@]}" "${_CPYTHON3_GLOBALLY_SUPPORTED_ABIS[@]}")
				python_minimal_version="${python_minimal_version:-${python_versions[0]}}"
				# Bash >=4.2:
				# python_maximal_version="${python_maximal_version:-${python_versions[-1]}}"
				python_maximal_version="${python_maximal_version:-${python_versions[${#python_versions[@]}-1]}}"
				_append_accepted_versions_range
			fi
		else
			if [[ "${python3}" == "1" ]]; then
				if [[ -z "${python3_minimal_version}" && -z "${python3_maximal_version}" ]]; then
					python_atoms+=("=dev-lang/python-3*")
				else
					python_versions=("${_CPYTHON3_GLOBALLY_SUPPORTED_ABIS[@]}")
					python_minimal_version="${python3_minimal_version:-${python_versions[0]}}"
					# Bash >=4.2:
					# python_maximal_version="${python3_maximal_version:-${python_versions[-1]}}"
					python_maximal_version="${python3_maximal_version:-${python_versions[${#python_versions[@]}-1]}}"
					_append_accepted_versions_range
				fi
			fi
			if [[ "${python2}" == "1" ]]; then
				if [[ -z "${python2_minimal_version}" && -z "${python2_maximal_version}" ]]; then
					python_atoms+=("=dev-lang/python-2*")
				else
					python_versions=("${_CPYTHON2_GLOBALLY_SUPPORTED_ABIS[@]}")
					python_minimal_version="${python2_minimal_version:-${python_versions[0]}}"
					# Bash >=4.2:
					# python_maximal_version="${python2_maximal_version:-${python_versions[-1]}}"
					python_maximal_version="${python2_maximal_version:-${python_versions[${#python_versions[@]}-1]}}"
					_append_accepted_versions_range
				fi
			fi
		fi

		unset -f _append_accepted_versions_range

		eval "${output_variable}=(\"\${python_atoms[@]}\")"
	else
		die "Invalid syntax of ${input_variable}"
	fi
}

_python_parse_dependencies_in_old_EAPIs() {
	local USE_flag variable variables version_components_group_regex version_components_groups

	version_components_group_regex="(2|3|\*)(:([[:digit:]]+\.[[:digit:]]+)?(:([[:digit:]]+\.[[:digit:]]+)?)?)?"
	version_components_groups="${!1}"
	variables="$2"

	if [[ "${version_components_groups}" =~ ^((\!)?[[:alnum:]_-]+\?\ )?${version_components_group_regex}(\ ${version_components_group_regex})?$ ]]; then
		if [[ "${version_components_groups}" =~ ^(\!)?[[:alnum:]_-]+\? ]]; then
			USE_flag="${version_components_groups%\? *}"
			version_components_groups="${version_components_groups#* }"
		fi

		_python_parse_versions_range "${version_components_groups}" "$1" _PYTHON_ATOMS

		if [[ "${#_PYTHON_ATOMS[@]}" -gt 1 ]]; then
			for variable in ${variables}; do
				eval "${variable}+=\"\${!variable:+ }\${USE_flag}\${USE_flag:+? ( }|| ( \${_PYTHON_ATOMS[@]} )\${USE_flag:+ )}\""
			done
		else
			for variable in ${variables}; do
				eval "${variable}+=\"\${!variable:+ }\${USE_flag}\${USE_flag:+? ( }\${_PYTHON_ATOMS[@]}\${USE_flag:+ )}\""
			done
		fi
	else
		die "Invalid syntax of $1"
	fi
}

unset _PYTHON_DEPEND_CHECKS_CODE _PYTHON_USE_FLAGS_CHECKS_CODE

_python_parse_dependencies_in_new_EAPIs() {
	local component cpython_abis=() cpython_atoms=() cpython_reversed_abis=() i input_value input_variable output_value output_variable output_variables PYTHON_ABI replace_whitespace_characters="1" required_USE_flags separate_components USE_dependencies USE_flag_prefix versions_range

	input_value="${!1}"
	input_variable="$1"
	output_variables="$2"

	if _python_abi_type single; then
		USE_flag_prefix="python_single_abi_"
	else
		USE_flag_prefix="python_abis_"
	fi

	if has "${EAPI:-0}" 4 5 && _python_abi_type multiple; then
		cpython_abis=(${_CPYTHON2_GLOBALLY_SUPPORTED_ABIS[@]} ${_CPYTHON3_GLOBALLY_SUPPORTED_ABIS[@]})
		for ((i = $((${#cpython_abis[@]} - 1)); i >= 0; i--)); do
			cpython_reversed_abis+=("${cpython_abis[${i}]}")
		done
	fi

	_get_matched_USE_dependencies() {
		local matched_USE_dependencies patterns separate_USE_dependencies USE_dependency

		if [[ -n "${USE_dependencies}" ]]; then
			separate_USE_dependencies="${USE_dependencies:1:$((${#USE_dependencies} - 2))}"
			separate_USE_dependencies="${separate_USE_dependencies//,/$'\n'}"
			while read -r USE_dependency; do
				if [[ "${USE_dependency}" == "{"*"}"* ]]; then
					patterns="${USE_dependency%\}*}"
					patterns="${patterns:1}"
					USE_dependency="${USE_dependency#*\}}"
					if _python_check_python_abi_matching --patterns-list "${PYTHON_ABI}" "${patterns}"; then
						matched_USE_dependencies+="${matched_USE_dependencies:+,}${USE_dependency}"
					fi
				else
					matched_USE_dependencies+="${matched_USE_dependencies:+,}${USE_dependency}"
				fi
			done <<< "${separate_USE_dependencies}"
			if [[ -n "${matched_USE_dependencies}" ]]; then
				matched_USE_dependencies="[${matched_USE_dependencies}]"
			fi
		fi

		echo "${matched_USE_dependencies}"
	}

	for ((i = 0; i < ${#input_value}; i++)); do
		if [[ "${input_value:${i}:1}" == "<" && "${input_value:$((${i} + 1)):1}" == "<" ]]; then
			replace_whitespace_characters="0"
			separate_components+="${input_value:${i}:1}"
		elif [[ "${input_value:${i}:1}" == ">" && "${input_value:$((${i} + 1)):1}" == ">" ]]; then
			replace_whitespace_characters="1"
			separate_components+="${input_value:${i}:1}"
		elif [[ "${input_value:${i}:1}" == [${IFS}] ]]; then
			if [[ "${replace_whitespace_characters}" == "1" ]]; then
				separate_components+=$'\n'
			else
				separate_components+="${input_value:${i}:1}"
			fi
		else
			separate_components+="${input_value:${i}:1}"
		fi
	done

	while read -r component; do
		if [[ -z "${component}" ]]; then
			continue
		elif [[ "${component}" == "<<"*">>" ]]; then
			component="${component:2:$((${#component} - 4))}"
			if [[ "${component}" == *"["*"]" ]]; then
				versions_range="${component%%\[*\]}"
				USE_dependencies="${component#${versions_range}}"
			else
				versions_range="${component}"
				USE_dependencies=""
			fi
			if _python_abi_type single || _python_abi_type multiple; then
				if [[ -n "${versions_range}" ]]; then
					die "Invalid syntax of ${input_variable}: Versions range can not be used in ebuilds setting PYTHON_ABI_TYPE variable"
				fi
				if has "${EAPI:-0}" 4 5 && _python_abi_type multiple; then
					cpython_atoms=()
					for PYTHON_ABI in "${cpython_reversed_abis[@]}"; do
						if ! _python_check_python_abi_matching --patterns-list "${PYTHON_ABI}" "${PYTHON_RESTRICTED_ABIS}"; then
							cpython_atoms+=("dev-lang/python:${PYTHON_ABI}$(_get_matched_USE_dependencies)")
						fi
					done
					if [[ "${#cpython_atoms[@]}" -gt 1 ]]; then
						output_value+="${output_value:+ }|| ( ${cpython_atoms[@]} )"
					else
						output_value+="${output_value:+ }${cpython_atoms[@]}"
					fi
					if [[ "${input_variable}" == "PYTHON_DEPEND" ]]; then
						_PYTHON_DEPEND_CHECKS_CODE+="${_PYTHON_DEPEND_CHECKS_CODE:+ }return 0;"
					fi
					if [[ -z "${USE_dependencies}" ]]; then
						_PYTHON_USE_FLAGS_CHECKS_CODE+="${_PYTHON_USE_FLAGS_CHECKS_CODE:+ }:;"
					fi
				fi
				if _python_abi_type single || { ! has "${EAPI:-0}" 4 5 && _python_abi_type multiple; }; then
					output_value+="${output_value:+ }("
				fi
				for PYTHON_ABI in "${_PYTHON_LOCALLY_SUPPORTED_ABIS[@]}"; do
					if has "${EAPI:-0}" 4 5 && _python_abi_type multiple; then
						if [[ -n "${USE_dependencies}" ]]; then
							_PYTHON_USE_FLAGS_CHECKS_CODE+="${_PYTHON_USE_FLAGS_CHECKS_CODE:+ }if [[ \"\${PYTHON_ABI}\" == \"${PYTHON_ABI}\" ]] && ! has_version \"\$(python_get_implementational_package)$(_get_matched_USE_dependencies)\"; then die \"\$(python_get_implementational_package)$(_get_matched_USE_dependencies) not installed in ROOT=\\\"\${ROOT}\\\"\"; fi;"
						fi
					else
						if [[ "${PYTHON_ABI}" =~ ^[[:digit:]]+\.[[:digit:]]+$ ]]; then
							output_value+="${output_value:+ }${USE_flag_prefix}${PYTHON_ABI}? ( dev-lang/python:${PYTHON_ABI}$(_get_matched_USE_dependencies) )"
						elif [[ "${PYTHON_ABI}" =~ ^[[:digit:]]+\.[[:digit:]]+-jython$ ]]; then
							output_value+="${output_value:+ }${USE_flag_prefix}${PYTHON_ABI}? ( dev-lang/jython:${PYTHON_ABI%-jython}$(_get_matched_USE_dependencies) )"
						elif [[ "${PYTHON_ABI}" =~ ^[[:digit:]]+\.[[:digit:]]+-pypy$ ]]; then
							if has "${EAPI:-0}" 4-python; then
								output_value+="${output_value:+ }${USE_flag_prefix}${PYTHON_ABI}? ( dev-lang/pypy:python-${PYTHON_ABI%-pypy}$(_get_matched_USE_dependencies) )"
							else
								output_value+="${output_value:+ }${USE_flag_prefix}${PYTHON_ABI}? ( dev-lang/pypy:python-${PYTHON_ABI%-pypy}=$(_get_matched_USE_dependencies) )"
							fi
						fi
					fi
				done
				if _python_abi_type single || { ! has "${EAPI:-0}" 4 5 && _python_abi_type multiple; }; then
					output_value+="${output_value:+ })"
					if [[ "${#_PYTHON_LOCALLY_SUPPORTED_ABIS[@]}" -gt 1 ]]; then
						if _python_abi_type single; then
							required_USE_flags+="${required_USE_flags:+ }^^ ( ${_PYTHON_LOCALLY_SUPPORTED_ABIS[@]/#/${USE_flag_prefix}} )"
						else
							required_USE_flags+="${required_USE_flags:+ }|| ( ${_PYTHON_LOCALLY_SUPPORTED_ABIS[@]/#/${USE_flag_prefix}} )"
						fi
					else
						required_USE_flags+="${required_USE_flags:+ }${_PYTHON_LOCALLY_SUPPORTED_ABIS[@]/#/${USE_flag_prefix}}"
					fi
				fi
			else
				_python_parse_versions_range "${versions_range}" "${input_variable}" cpython_atoms
				cpython_atoms=("${cpython_atoms[@]/%/${USE_dependencies}}")
				if [[ "${#cpython_atoms[@]}" -gt 1 ]]; then
					output_value+="${output_value:+ }|| ( ${cpython_atoms[@]} )"
				else
					output_value+="${output_value:+ }${cpython_atoms[@]}"
				fi
				if [[ "${input_variable}" == "PYTHON_DEPEND" ]]; then
					_PYTHON_DEPEND_CHECKS_CODE+="${_PYTHON_DEPEND_CHECKS_CODE:+ }return 0;"
				fi
				if [[ -n "${USE_dependencies}" ]]; then
					_PYTHON_USE_FLAGS_CHECKS_CODE+="${_PYTHON_USE_FLAGS_CHECKS_CODE:+ }if ! has_version \"\$(python_get_implementational_package)${USE_dependencies}\"; then die \"\$(python_get_implementational_package)${USE_dependencies} not installed in ROOT=\\\"\${ROOT}\\\"\"; fi;"
				else
					_PYTHON_USE_FLAGS_CHECKS_CODE+="${_PYTHON_USE_FLAGS_CHECKS_CODE:+ }:;"
				fi
			fi
		elif [[ "${component}" == *"?" ]]; then
			output_value+="${output_value:+ }${component}"
			required_USE_flags+="${required_USE_flags:+ }${component}"
			if [[ "${input_variable}" == "PYTHON_DEPEND" ]]; then
				_PYTHON_DEPEND_CHECKS_CODE+="${_PYTHON_DEPEND_CHECKS_CODE:+ }if use ${component%\?};"
			fi
			_PYTHON_USE_FLAGS_CHECKS_CODE+="${_PYTHON_USE_FLAGS_CHECKS_CODE:+ }if use ${component%\?};"
		elif [[ "${component}" == "||" ]]; then
			if has "${EAPI:-0}" 4 5 || _python_abi_type implicit_single; then
				die "Invalid syntax of ${input_variable}: Unrecognized component '${component}'"
			fi
			output_value+="${output_value:+ }${component}"
			required_USE_flags+="${required_USE_flags:+ }${component}"
		elif [[ "${component}" == "(" ]]; then
			output_value+="${output_value:+ }${component}"
			required_USE_flags+="${required_USE_flags:+ }${component}"
			if [[ "${input_variable}" == "PYTHON_DEPEND" ]]; then
				_PYTHON_DEPEND_CHECKS_CODE+="${_PYTHON_DEPEND_CHECKS_CODE:+ }then"
			fi
			_PYTHON_USE_FLAGS_CHECKS_CODE+="${_PYTHON_USE_FLAGS_CHECKS_CODE:+ }then"
		elif [[ "${component}" == ")" ]]; then
			output_value+="${output_value:+ }${component}"
			required_USE_flags+="${required_USE_flags:+ }${component}"
			if [[ "${input_variable}" == "PYTHON_DEPEND" ]]; then
				_PYTHON_DEPEND_CHECKS_CODE+="${_PYTHON_DEPEND_CHECKS_CODE:+ }fi;"
			fi
			_PYTHON_USE_FLAGS_CHECKS_CODE+="${_PYTHON_USE_FLAGS_CHECKS_CODE:+ }fi;"
		else
			die "Invalid syntax of ${input_variable}: Unrecognized component '${component}'"
		fi
	done <<< "${separate_components}"

	for output_variable in ${output_variables}; do
		eval "${output_variable}+=\"\${!output_variable:+ }\${output_value}\""
	done


	if _python_abi_type single || { ! has "${EAPI:-0}" 4 5 && _python_abi_type multiple; }; then
		REQUIRED_USE+="${REQUIRED_USE:+ }${required_USE_flags}"
	fi

	unset -f _get_matched_USE_dependencies
}

if _python_implementation; then
	DEPEND=">=app-eselect/eselect-python-20091230 >=app-shells/bash-4.2"
	RDEPEND="${DEPEND}"
fi

if has "${EAPI:-0}" 0 1 2 3 || { has "${EAPI:-0}" 4 5 && has "${PYTHON_ECLASS_API}" 0; }; then
	_PYTHON_ATOMS_FROM_PYTHON_DEPEND=()
	_PYTHON_ATOMS_FROM_PYTHON_BDEPEND=()
	if [[ -z "${PYTHON_DEPEND}" && -z "${PYTHON_BDEPEND}" ]]; then
		_PYTHON_ATOMS_FROM_PYTHON_DEPEND=("dev-lang/python")
	fi
	if [[ -n "${PYTHON_DEPEND}" ]]; then
		_python_parse_dependencies_in_old_EAPIs PYTHON_DEPEND "DEPEND RDEPEND"
		_PYTHON_ATOMS_FROM_PYTHON_DEPEND=("${_PYTHON_ATOMS[@]}")
	fi
	if [[ -n "${PYTHON_BDEPEND}" ]]; then
		_python_parse_dependencies_in_old_EAPIs PYTHON_BDEPEND "DEPEND"
		_PYTHON_ATOMS_FROM_PYTHON_BDEPEND=("${_PYTHON_ATOMS[@]}")
	fi
	unset _PYTHON_ATOMS
else
	if [[ -z "$(declare -p PYTHON_DEPEND 2> /dev/null)" ]] && { _python_abi_type single || _python_abi_type multiple; }; then
		PYTHON_DEPEND="<<>>"
	fi
	if [[ -n "${PYTHON_DEPEND}" ]]; then
		_python_parse_dependencies_in_new_EAPIs PYTHON_DEPEND "DEPEND RDEPEND"
	fi
	if [[ -n "${PYTHON_BDEPEND}" ]]; then
		_python_parse_dependencies_in_new_EAPIs PYTHON_BDEPEND "DEPEND"
	fi
	if _python_abi_type single || { ! has "${EAPI:-0}" 4 5 && _python_abi_type multiple; }; then
		unset _PYTHON_DEPEND_CHECKS_CODE _PYTHON_USE_FLAGS_CHECKS_CODE
	else
		_PYTHON_DEPEND_CHECKS_CODE="${_PYTHON_DEPEND_CHECKS_CODE%;}"
		_PYTHON_USE_FLAGS_CHECKS_CODE="${_PYTHON_USE_FLAGS_CHECKS_CODE%;}"
	fi
fi
unset -f _python_parse_versions_range _python_parse_dependencies_in_old_EAPIs _python_parse_dependencies_in_new_EAPIs

# @ECLASS-VARIABLE: PYTHON_USE_WITH
# @DESCRIPTION:
# Set this to a space separated list of USE flags the Python slot in use must be built with.
# This variable can be used only in:
#   EAPI="2"
#   EAPI="3"
#   EAPI="4" + PYTHON_ECLASS_API="0"
#   EAPI="5" + PYTHON_ECLASS_API="0"

# @ECLASS-VARIABLE: PYTHON_USE_WITH_OR
# @DESCRIPTION:
# Set this to a space separated list of USE flags of which one must be turned on for the slot in use.
# This variable is ignored when PYTHON_USE_WITH is set.
# This variable can be used only in:
#   EAPI="2"
#   EAPI="3"
#   EAPI="4" + PYTHON_ECLASS_API="0"
#   EAPI="5" + PYTHON_ECLASS_API="0"

# @ECLASS-VARIABLE: PYTHON_USE_WITH_OPT
# @DESCRIPTION:
# Set this to a name of a USE flag if you need to make either PYTHON_USE_WITH or
# PYTHON_USE_WITH_OR atoms conditional under a USE flag.
# This variable can be used only in:
#   EAPI="2"
#   EAPI="3"
#   EAPI="4" + PYTHON_ECLASS_API="0"
#   EAPI="5" + PYTHON_ECLASS_API="0"

if has "${EAPI:-0}" 2 3 || { has "${EAPI:-0}" 4 5 && has "${PYTHON_ECLASS_API}" 0; }; then
	if [[ -n "${PYTHON_USE_WITH}" || -n "${PYTHON_USE_WITH_OR}" ]]; then
		_PYTHON_USE_WITH_ATOMS_ARRAY_FROM_PYTHON_DEPEND=()
		_PYTHON_USE_WITH_ATOMS_ARRAY_FROM_PYTHON_BDEPEND=()
		if [[ -n "${PYTHON_USE_WITH}" ]]; then
			for _PYTHON_ATOM in "${_PYTHON_ATOMS_FROM_PYTHON_DEPEND[@]}"; do
				_PYTHON_USE_WITH_ATOMS_ARRAY_FROM_PYTHON_DEPEND+=("${_PYTHON_ATOM}[${PYTHON_USE_WITH// /,}]")
			done
			for _PYTHON_ATOM in "${_PYTHON_ATOMS_FROM_PYTHON_BDEPEND[@]}"; do
				_PYTHON_USE_WITH_ATOMS_ARRAY_FROM_PYTHON_BDEPEND+=("${_PYTHON_ATOM}[${PYTHON_USE_WITH// /,}]")
			done
		elif [[ -n "${PYTHON_USE_WITH_OR}" ]]; then
			for _USE_flag in ${PYTHON_USE_WITH_OR}; do
				for _PYTHON_ATOM in "${_PYTHON_ATOMS_FROM_PYTHON_DEPEND[@]}"; do
					_PYTHON_USE_WITH_ATOMS_ARRAY_FROM_PYTHON_DEPEND+=("${_PYTHON_ATOM}[${_USE_flag}]")
				done
				for _PYTHON_ATOM in "${_PYTHON_ATOMS_FROM_PYTHON_BDEPEND[@]}"; do
					_PYTHON_USE_WITH_ATOMS_ARRAY_FROM_PYTHON_BDEPEND+=("${_PYTHON_ATOM}[${_USE_flag}]")
				done
			done
			unset _USE_flag
		fi
		if [[ "${#_PYTHON_ATOMS_FROM_PYTHON_DEPEND[@]}" -gt 0 ]]; then
			if [[ "${#_PYTHON_USE_WITH_ATOMS_ARRAY_FROM_PYTHON_DEPEND[@]}" -gt 1 ]]; then
				_PYTHON_USE_WITH_ATOMS_FROM_PYTHON_DEPEND="|| ( ${_PYTHON_USE_WITH_ATOMS_ARRAY_FROM_PYTHON_DEPEND[@]} )"
			else
				_PYTHON_USE_WITH_ATOMS_FROM_PYTHON_DEPEND="${_PYTHON_USE_WITH_ATOMS_ARRAY_FROM_PYTHON_DEPEND[@]}"
			fi
			if [[ -n "${PYTHON_USE_WITH_OPT}" ]]; then
				_PYTHON_USE_WITH_ATOMS_FROM_PYTHON_DEPEND="${PYTHON_USE_WITH_OPT}? ( ${_PYTHON_USE_WITH_ATOMS_FROM_PYTHON_DEPEND} )"
			fi
			DEPEND+="${DEPEND:+ }${_PYTHON_USE_WITH_ATOMS_FROM_PYTHON_DEPEND}"
			RDEPEND+="${RDEPEND:+ }${_PYTHON_USE_WITH_ATOMS_FROM_PYTHON_DEPEND}"
		fi
		if [[ "${#_PYTHON_ATOMS_FROM_PYTHON_BDEPEND[@]}" -gt 0 ]]; then
			if [[ "${#_PYTHON_USE_WITH_ATOMS_ARRAY_FROM_PYTHON_BDEPEND[@]}" -gt 1 ]]; then
				_PYTHON_USE_WITH_ATOMS_FROM_PYTHON_BDEPEND="|| ( ${_PYTHON_USE_WITH_ATOMS_ARRAY_FROM_PYTHON_BDEPEND[@]} )"
			else
				_PYTHON_USE_WITH_ATOMS_FROM_PYTHON_BDEPEND="${_PYTHON_USE_WITH_ATOMS_ARRAY_FROM_PYTHON_BDEPEND[@]}"
			fi
			if [[ -n "${PYTHON_USE_WITH_OPT}" ]]; then
				_PYTHON_USE_WITH_ATOMS_FROM_PYTHON_BDEPEND="${PYTHON_USE_WITH_OPT}? ( ${_PYTHON_USE_WITH_ATOMS_FROM_PYTHON_BDEPEND} )"
			fi
			DEPEND+="${DEPEND:+ }${_PYTHON_USE_WITH_ATOMS_FROM_PYTHON_BDEPEND}"
		fi
		unset _PYTHON_ATOM _PYTHON_USE_WITH_ATOMS_FROM_PYTHON_DEPEND _PYTHON_USE_WITH_ATOMS_ARRAY_FROM_PYTHON_DEPEND _PYTHON_USE_WITH_ATOMS_FROM_PYTHON_BDEPEND _PYTHON_USE_WITH_ATOMS_ARRAY_FROM_PYTHON_BDEPEND
	fi
else
	if [[ -n "${PYTHON_USE_WITH}" ]]; then
		eerror "Use PYTHON_DEPEND variable instead of PYTHON_USE_WITH variable."
		die "PYTHON_USE_WITH variable is banned"
	fi
	if [[ -n "${PYTHON_USE_WITH_OR}" ]]; then
		eerror "Use PYTHON_DEPEND variable instead of PYTHON_USE_WITH_OR variable."
		die "PYTHON_USE_WITH_OR variable is banned"
	fi
	if [[ -n "${PYTHON_USE_WITH_OPT}" ]]; then
		eerror "Use PYTHON_DEPEND variable instead of PYTHON_USE_WITH_OPT variable."
		die "PYTHON_USE_WITH_OPT variable is banned"
	fi
fi

if has "${EAPI:-0}" 0 1 2 3 || { has "${EAPI:-0}" 4 5 && has "${PYTHON_ECLASS_API}" 0; }; then
	unset _PYTHON_ATOMS_FROM_PYTHON_DEPEND _PYTHON_ATOMS_FROM_PYTHON_BDEPEND
fi

# @FUNCTION: python_abi_depend
# @USAGE: [-e|--exclude-ABIs Python_ABIs] [-i|--include-ABIs Python_ABIs] [--] <dependency_atom> [dependency_atoms]
# @DESCRIPTION:
# Print dependency atoms with USE dependencies for Python ABIs added.
# If --exclude-ABIs option is specified, then Python ABIs matching its argument are not used.
# If --include-ABIs option is specified, then only Python ABIs matching its argument are used.
# --exclude-ABIs and --include-ABIs options can not be specified simultaneously.
python_abi_depend() {
	if has "${EAPI:-0}" 0 1 2 3 4 5; then
		die "${FUNCNAME}() can not be used in EAPI=\"${EAPI}\""
	fi

	if ! _python_abi_type single && ! _python_abi_type multiple; then
		die "${FUNCNAME}() can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"single\" or PYTHON_ABI_TYPE=\"multiple\" variable"
	fi

	local atom atom_index atoms=() exclude_ABIs="0" excluded_ABIs include_ABIs="0" included_ABIs iterated_PYTHON_ABIS=() PYTHON_ABI PYTHON_ABI_index USE_dependencies

	while (($#)); do
		case "$1" in
			-e|--exclude-ABIs)
				exclude_ABIs="1"
				excluded_ABIs="$2"
				shift
				;;
			-i|--include-ABIs)
				include_ABIs="1"
				included_ABIs="$2"
				shift
				;;
			--)
				shift
				break
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				break
				;;
		esac
		shift
	done

	if [[ "${exclude_ABIs}" == "1" && "${include_ABIs}" == "1" ]]; then
		die "${FUNCNAME}(): '--exclude-ABIs' and '--include-ABIs' options can not be specified simultaneously"
	fi

	if [[ "$#" -eq 0 ]]; then
		die "${FUNCNAME}(): Missing dependency atoms"
	fi

	atoms=("$@")

	if _python_abi_type multiple && [[ "${exclude_ABIs}" == "0" && "${include_ABIs}" == "0" ]]; then
		USE_dependencies="$(printf ",python_abis_%s?" "${_PYTHON_LOCALLY_SUPPORTED_ABIS[@]}")"
		USE_dependencies="${USE_dependencies#,}"

		for atom_index in "${!atoms[@]}"; do
			atom="${atoms[${atom_index}]}"

			if [[ "${atom}" == *"["*"]" ]]; then
				echo -n "${atom%]},"
			else
				echo -n "${atom}["
			fi
			echo -n "${USE_dependencies}]"

			if [[ "${atom_index}" -ne $((${#atoms[@]} - 1)) ]]; then
				echo -n " "
			fi
		done
	else
		if [[ "${exclude_ABIs}" == "1" ]]; then
			for PYTHON_ABI in "${_PYTHON_LOCALLY_SUPPORTED_ABIS[@]}"; do
				if ! _python_check_python_abi_matching --patterns-list "${PYTHON_ABI}" "${excluded_ABIs}"; then
					iterated_PYTHON_ABIS+=("${PYTHON_ABI}")
				fi
			done

			if [[ "${#iterated_PYTHON_ABIS[@]}" -eq 0 ]]; then
				ewarn "'${EBUILD}':"
				ewarn "${FUNCNAME}(): Python ABIs patterns list '${excluded_ABIs}' excludes all locally supported Python ABIs"
			elif [[ "${#iterated_PYTHON_ABIS[@]}" -eq "${#_PYTHON_LOCALLY_SUPPORTED_ABIS[@]}" ]]; then
				ewarn "'${EBUILD}':"
				ewarn "${FUNCNAME}(): Python ABIs patterns list '${excluded_ABIs}' excludes no locally supported Python ABIs"
			fi
		elif [[ "${include_ABIs}" == "1" ]]; then
			for PYTHON_ABI in "${_PYTHON_LOCALLY_SUPPORTED_ABIS[@]}"; do
				if _python_check_python_abi_matching --patterns-list "${PYTHON_ABI}" "${included_ABIs}"; then
					iterated_PYTHON_ABIS+=("${PYTHON_ABI}")
				fi
			done

			if [[ "${#iterated_PYTHON_ABIS[@]}" -eq 0 ]]; then
				ewarn "'${EBUILD}':"
				ewarn "${FUNCNAME}(): Python ABIs patterns list '${included_ABIs}' includes no locally supported Python ABIs"
			elif [[ "${#iterated_PYTHON_ABIS[@]}" -eq "${#_PYTHON_LOCALLY_SUPPORTED_ABIS[@]}" ]]; then
				ewarn "'${EBUILD}':"
				ewarn "${FUNCNAME}(): Python ABIs patterns list '${included_ABIs}' includes all locally supported Python ABIs"
			fi
		elif _python_abi_type single; then
			iterated_PYTHON_ABIS=("${_PYTHON_LOCALLY_SUPPORTED_ABIS[@]}")
		else
			die "${FUNCNAME}(): Internal error"
		fi

		if [[ "${#iterated_PYTHON_ABIS[@]}" -gt 1 ]]; then
			echo -n "( "
		fi

		for PYTHON_ABI_index in "${!iterated_PYTHON_ABIS[@]}"; do
			PYTHON_ABI="${iterated_PYTHON_ABIS[${PYTHON_ABI_index}]}"

			if _python_abi_type single; then
				echo -n "python_single_abi_${PYTHON_ABI}? ( "
			else
				echo -n "python_abis_${PYTHON_ABI}? ( "
			fi

			for atom_index in "${!atoms[@]}"; do
				atom="${atoms[${atom_index}]}"

				if _python_abi_type single; then
					echo -n "|| ( "

					if [[ "${atom}" == *"["*"]" ]]; then
						echo -n "${atom%]},"
					else
						echo -n "${atom}["
					fi
					echo -n "python_abis_${PYTHON_ABI}]"

					echo -n " "

					if [[ "${atom}" == *"["*"]" ]]; then
						echo -n "${atom%]},"
					else
						echo -n "${atom}["
					fi
					echo -n "python_single_abi_${PYTHON_ABI}]"

					echo -n " )"
				else
					if [[ "${atom}" == *"["*"]" ]]; then
						echo -n "${atom%]},"
					else
						echo -n "${atom}["
					fi
					echo -n "python_abis_${PYTHON_ABI}]"
				fi

				if [[ "${atom_index}" -ne $((${#atoms[@]} - 1)) ]]; then
					echo -n " "
				fi
			done

			echo -n " )"

			if [[ "${PYTHON_ABI_index}" -ne $((${#iterated_PYTHON_ABIS[@]} - 1)) ]]; then
				echo -n " "
			fi
		done

		if [[ "${#iterated_PYTHON_ABIS[@]}" -gt 1 ]]; then
			echo -n " )"
		fi
	fi
}

# ========================================================================================================================
# =============================================== MISCELLANEOUS FUNCTIONS ================================================
# ========================================================================================================================

_python_check_run-time_dependency() {
	if has "${EAPI:-0}" 0 1 2 3 || { has "${EAPI:-0}" 4 5 && has "${PYTHON_ECLASS_API}" 0; }; then
		return 0
	else
		if _python_abi_type single || { ! has "${EAPI:-0}" 4 5 && _python_abi_type multiple; }; then
			die "${FUNCNAME}() called illegally"
		fi

		eval "${_PYTHON_DEPEND_CHECKS_CODE}"
		return 1
	fi
}

_python_prepare_jython() {
	local build_group build_user current_group current_user iterated_PYTHON_ABIS jython_version PYTHON_ABI="${PYTHON_ABI}"

	export JYTHON_SYSTEM_CACHEDIR="1"
	addwrite "${EPREFIX}/var/cache/jython"

	current_user="$(id -un)" || die "${FUNCNAME}(): Extraction of current user failed"
	current_group="$(id -gn)" || die "${FUNCNAME}(): Extraction of current group failed"
	if has "${EAPI:-0}" 5-progress && declare -f package_manager_build_user > /dev/null; then
		build_user="$(package_manager_build_user)" || die "${FUNCNAME}(): Extraction of build user failed"
		build_group="$(package_manager_build_group)" || die "${FUNCNAME}(): Extraction of build group failed"
	fi

	if _python_abi_type single; then
		iterated_PYTHON_ABIS="${PYTHON_SINGLE_ABI}"
	elif _python_abi_type multiple; then
		iterated_PYTHON_ABIS="${PYTHON_ABIS}"
	else
		iterated_PYTHON_ABIS="${PYTHON_ABI}"
	fi

	for PYTHON_ABI in ${iterated_PYTHON_ABIS}; do
		if has "${PYTHON_ABI}" "${_JYTHON_GLOBALLY_SUPPORTED_ABIS[@]}"; then
			jython_version="${PYTHON_ABI%-jython}"
			mkdir -p "${EPREFIX}/var/cache/jython/${jython_version}-${current_user}" || die "${FUNCNAME}(): Creation of '${EPREFIX}/var/cache/jython/${jython_version}-${current_user}' directory failed"
			chown -R "${current_user}:${current_group}" "${EPREFIX}/var/cache/jython/${jython_version}-${current_user}" || die "${FUNCNAME}(): Changing of owner and group of '${EPREFIX}/var/cache/jython/${jython_version}-${current_user}' directory to ${current_user}:${current_group} failed"
			if has "${EAPI:-0}" 5-progress && declare -f package_manager_build_user > /dev/null && [[ "${current_user}" != "${build_user}" ]]; then
				mkdir -p "${EPREFIX}/var/cache/jython/${jython_version}-${build_user}" || die "${FUNCNAME}(): Creation of '${EPREFIX}/var/cache/jython/${jython_version}-${build_user}' directory failed"
				chown -R "${build_user}:${build_group}" "${EPREFIX}/var/cache/jython/${jython_version}-${build_user}" || die "${FUNCNAME}(): Changing of owner and group of '${EPREFIX}/var/cache/jython/${jython_version}-${build_user}' directory to ${build_user}:${build_group} failed"
			fi
		fi
	done
}

_python_abi-specific_local_scope() {
	[[ " ${FUNCNAME[@]:2} " =~ " "(_python_final_sanity_checks|python_execute_function|python_byte-compile_modules|python_clean_byte-compiled_modules|python_generate_cffi_modules)" " ]]
}

_python_initialize_prefix_variables() {
	if has "${EAPI:-0}" 0 1 2; then
		if [[ -n "${ROOT}" && -z "${EROOT}" ]]; then
			EROOT="${ROOT%/}${EPREFIX}/"
		fi
		if [[ -n "${D}" && -z "${ED}" ]]; then
			ED="${D%/}${EPREFIX}/"
		fi
	fi
}

unset PYTHON_SANITY_CHECKS_EXECUTED PYTHON_SKIP_SANITY_CHECKS

_python_initial_sanity_checks() {
	if [[ "$(declare -p PYTHON_SANITY_CHECKS_EXECUTED 2> /dev/null)" != "declare -- PYTHON_SANITY_CHECKS_EXECUTED="* || " ${FUNCNAME[@]:1} " =~ " "(python_set_active_version|python_pkg_setup)" " && -z "${PYTHON_SKIP_SANITY_CHECKS}" ]]; then
		# Ensure that /usr/bin/python and /usr/bin/python-config are valid.
		if [[ "$(readlink "${EPREFIX}/usr/bin/python")" != "python-wrapper" ]]; then
			eerror "'${EPREFIX}/usr/bin/python' is not valid symlink."
			eerror "Use \`eselect python set \${python_interpreter}\` to fix this problem."
			die "'${EPREFIX}/usr/bin/python' is not valid symlink"
		fi
		if [[ "$(<"${EPREFIX}/usr/bin/python-config")" != *"Gentoo python-config wrapper script"* ]]; then
			eerror "'${EPREFIX}/usr/bin/python-config' is not valid script"
			eerror "Use \`eselect python set \${python_interpreter}\` to fix this problem."
			die "'${EPREFIX}/usr/bin/python-config' is not valid script"
		fi
	fi
}

_python_final_sanity_checks() {
	if ! _python_implementation && [[ "$(declare -p PYTHON_SANITY_CHECKS_EXECUTED 2> /dev/null)" != "declare -- PYTHON_SANITY_CHECKS_EXECUTED="* || " ${FUNCNAME[@]:1} " =~ " "(python_set_active_version|python_pkg_setup)" " && -z "${PYTHON_SKIP_SANITY_CHECKS}" ]]; then
		local iterated_PYTHON_ABIS PYTHON_ABI="${PYTHON_ABI}"

		if _python_abi_type multiple; then
			iterated_PYTHON_ABIS="${PYTHON_ABIS}"
		else
			iterated_PYTHON_ABIS="${PYTHON_ABI}"
		fi

		for PYTHON_ABI in ${iterated_PYTHON_ABIS}; do
			# Ensure that appropriate version of Python is installed.
			if has "${EAPI:-0}" 0 1 2 3 4 5 || { ! has "${EAPI:-0}" 0 1 2 3 4 5 && ! _python_abi_type single && ! _python_abi_type multiple; }; then
				if ! ROOT="/" has_version "$(python_get_implementational_package)"; then
					die "$(python_get_implementational_package) not installed in ROOT=\"/\""
				fi
				if [[ "${ROOT}" != "/" ]] && _python_check_run-time_dependency; then
					if ! has_version "$(python_get_implementational_package)"; then
						die "$(python_get_implementational_package) not installed in ROOT=\"${ROOT}\""
					fi
				fi
			else
				if ! type -p "${EPREFIX}$(PYTHON -a)" > /dev/null && ! ROOT="/" has_version "$(python_get_implementational_package)"; then
					die "$(python_get_implementational_package) not installed in ROOT=\"/\""
				fi
			fi

			# Ensure that EPYTHON variable is respected.
			if [[ "$(EPYTHON="$(PYTHON)" python -c "${_PYTHON_ABI_EXTRACTION_COMMAND}")" != "${PYTHON_ABI}" ]]; then
				eerror "Path to 'python':                 '$(type -p python)'"
				eerror "ABI:                              '${ABI}'"
				eerror "DEFAULT_ABI:                      '${DEFAULT_ABI}'"
				eerror "EPYTHON:                          '$(PYTHON)'"
				eerror "PYTHON_ABI:                       '${PYTHON_ABI}'"
				eerror "Locally active version of Python: '$(EPYTHON="$(PYTHON)" python -c "${_PYTHON_ABI_EXTRACTION_COMMAND}")'"
				die "'python' does not respect EPYTHON variable"
			fi
		done
	fi
	PYTHON_SANITY_CHECKS_EXECUTED="1"
}

# @ECLASS-VARIABLE: PYTHON_COLORS
# @DESCRIPTION:
# User-configurable colored output.
PYTHON_COLORS="${PYTHON_COLORS:-1}"

_python_set_color_variables() {
	if [[ "${PYTHON_COLORS}" != "0" && "${NOCOLOR:-false}" =~ ^(false|no)$ ]]; then
		_BOLD=$'\e[1m'
		_RED=$'\e[1;31m'
		_GREEN=$'\e[1;32m'
		_BLUE=$'\e[1;34m'
		_CYAN=$'\e[1;36m'
		_NORMAL=$'\e[0m'
	else
		_BOLD=
		_RED=
		_GREEN=
		_BLUE=
		_CYAN=
		_NORMAL=
	fi
}

unset PYTHON_PKG_SETUP_EXECUTED

_python_check_python_pkg_setup_execution() {
	[[ " ${FUNCNAME[@]:1} " =~ " "(python_set_active_version|python_pkg_setup)" " ]] && return

	if ! has "${EAPI:-0}" 0 1 2 3 && [[ -z "${PYTHON_PKG_SETUP_EXECUTED}" ]]; then
		die "python_pkg_setup() not called"
	fi
}

# @FUNCTION: python_pkg_setup
# @DESCRIPTION:
# Perform sanity checks and initialize environment.
#
# This function is exported in EAPI 2 and 3 when PYTHON_USE_WITH or PYTHON_USE_WITH_OR variable
# is set and always in EAPI >=4. Calling of this function is mandatory in EAPI >=4.
python_pkg_setup() {
	if [[ "${EBUILD_PHASE}" != "setup" ]]; then
		die "${FUNCNAME}() can be used only in pkg_setup() phase"
	fi

	if [[ "$#" -ne 0 ]]; then
		die "${FUNCNAME}() does not accept arguments"
	fi

	if [[ "${BASH_VERSINFO[0]}" -lt 4 || "${BASH_VERSINFO[0]}" -eq 4 && "${BASH_VERSINFO[1]}" -lt 2 ]]; then
		die ">=app-shells/bash-4.2 required"
	fi

	if _python_abi_type single; then
		if [[ -z "${PYTHON_SINGLE_ABI}" || "${PYTHON_SINGLE_ABI}" =~ [${IFS}] ]]; then
			die "Invalid PYTHON_SINGLE_ABI=\"${PYTHON_SINGLE_ABI}\" variable"
		fi
	elif ! has "${EAPI:-0}" 0 1 2 3 4 5 && _python_abi_type multiple; then
		if [[ -z "${PYTHON_ABIS}" ]]; then
			die "Invalid PYTHON_ABIS=\"${PYTHON_ABIS}\" variable"
		fi
	fi

	_python_prepare_jython

	if _python_abi_type single; then
		PYTHON_ABI="${PYTHON_SINGLE_ABI}"
		_python_initial_sanity_checks
		_python_final_sanity_checks
		export EPYTHON="$(PYTHON "${PYTHON_ABI}")"
	elif _python_abi_type multiple; then
		if has "${EAPI:-0}" 0 1 2 3 4 5; then
			_python_calculate_PYTHON_ABIS
		else
			_python_initial_sanity_checks
			_python_final_sanity_checks
		fi
		export EPYTHON="$(PYTHON -f)"
	else
		PYTHON_ABI="${PYTHON_ABI:-$(PYTHON --ABI)}"
	fi

	if { has "${EAPI:-0}" 2 3 || { has "${EAPI:-0}" 4 5 && has "${PYTHON_ECLASS_API}" 0; }; } && [[ -n "${PYTHON_USE_WITH}" || -n "${PYTHON_USE_WITH_OR}" ]]; then
		if [[ "${PYTHON_USE_WITH_OPT}" ]]; then
			if [[ "${PYTHON_USE_WITH_OPT}" == !* ]]; then
				use ${PYTHON_USE_WITH_OPT#!} && return
			else
				use !${PYTHON_USE_WITH_OPT} && return
			fi
		fi

		python_pkg_setup_check_USE_flags() {
			local python_atom USE_flag
			python_atom="$(python_get_implementational_package)"

			for USE_flag in ${PYTHON_USE_WITH}; do
				if ! has_version "${python_atom}[${USE_flag}]"; then
					eerror "Please rebuild ${python_atom} with the following USE flags enabled: ${PYTHON_USE_WITH}"
					die "Please rebuild ${python_atom} with the following USE flags enabled: ${PYTHON_USE_WITH}"
				fi
			done

			for USE_flag in ${PYTHON_USE_WITH_OR}; do
				if has_version "${python_atom}[${USE_flag}]"; then
					return
				fi
			done

			if [[ ${PYTHON_USE_WITH_OR} ]]; then
				eerror "Please rebuild ${python_atom} with at least one of the following USE flags enabled: ${PYTHON_USE_WITH_OR}"
				die "Please rebuild ${python_atom} with at least one of the following USE flags enabled: ${PYTHON_USE_WITH_OR}"
			fi
		}

		if _python_abi_type multiple; then
			PYTHON_SKIP_SANITY_CHECKS="1" python_execute_function -q python_pkg_setup_check_USE_flags
		else
			python_pkg_setup_check_USE_flags
		fi

		unset -f python_pkg_setup_check_USE_flags
	fi

	if { has "${EAPI:-0}" 4 5 && ! has "${PYTHON_ECLASS_API}" 0; } || { ! has "${EAPI:-0}" 0 1 2 3 4 5 && ! _python_abi_type single && ! _python_abi_type multiple; }; then
		python_pkg_setup_check_USE_flags() {
			ROOT="/" eval "${_PYTHON_USE_FLAGS_CHECKS_CODE}"
			if [[ "${ROOT}" != "/" ]] && _python_check_run-time_dependency; then
				eval "${_PYTHON_USE_FLAGS_CHECKS_CODE}"
			fi
		}

		if _python_abi_type multiple; then
			PYTHON_SKIP_SANITY_CHECKS="1" python_execute_function -q python_pkg_setup_check_USE_flags
		else
			python_pkg_setup_check_USE_flags
		fi

		unset -f python_pkg_setup_check_USE_flags
	fi

	if ! _python_implementation; then
		declare -Ag _PYTHON_VERSIONS=()

		python_pkg_setup_prepare_global_variables() {
			local python_version

			python_version="$(ROOT="/" best_version "$(python_get_implementational_package)")"

			if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "CPython" ]]; then
				python_version="${python_version#dev-lang/python-}"
			elif [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "Jython" ]]; then
				python_version="${python_version#dev-lang/jython-}"
			elif [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "PyPy" ]]; then
				python_version="${python_version#dev-lang/pypy-}"
			fi

			_PYTHON_VERSIONS["${PYTHON_ABI}"]="${python_version}"
		}

		if _python_abi_type multiple; then
			PYTHON_SKIP_SANITY_CHECKS="1" python_execute_function -q python_pkg_setup_prepare_global_variables
		else
			python_pkg_setup_prepare_global_variables
		fi

		unset -f python_pkg_setup_prepare_global_variables
	fi

	PYTHON_PKG_SETUP_EXECUTED="1"
}

if ! has "${EAPI:-0}" 0 1 2 3 || { has "${EAPI:-0}" 2 3 && [[ -n "${PYTHON_USE_WITH}" || -n "${PYTHON_USE_WITH_OR}" ]]; }; then
	EXPORT_FUNCTIONS pkg_setup
fi

# @FUNCTION: python_execute
# @USAGE: [variables] <command> [arguments]
# @DESCRIPTION:
# Print and execute specified command.
python_execute() {
	_python_check_python_pkg_setup_execution
	_python_set_color_variables

	local argument letters printed_command=()

	letters="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

	for argument in "$@"; do
		if [[ "${argument}" =~ ^[${letters}_][${letters}0123456789_]*= ]]; then
			printed_command+=("${argument%%=*}=\"${argument#*=}\"")
		else
			if [[ -z "${argument}" || "${argument}" =~ [${IFS}] ]]; then
				printed_command+=("\"${argument}\"")
			else
				printed_command+=("${argument}")
			fi
		fi
	done

	while (($#)); do
		if [[ "$1" =~ ^[${letters}_][${letters}0123456789_]*= ]]; then
			local -x "$1"
		else
			break
		fi
		shift
	done

	if [[ "$#" -eq 0 ]]; then
		die "${FUNCNAME}(): Missing command"
	fi

	echo "${_BOLD}""${printed_command[@]}""${_NORMAL}"
	"$@"
}

_python_execute_with_build_environment() {
	local compiler_options file linker_options variable verbose_executables="0"

	while (($#)); do
		case "$1" in
			--verbose-executables)
				verbose_executables="1"
				;;
			--)
				shift
				break
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				break
				;;
		esac
		shift
	done

	if [[ "${CHOST}" == *-aix* ]]; then
		compiler_options=""
		linker_options="-shared -Wl,-berok"
	elif [[ "${CHOST}" == *-darwin* ]]; then
		compiler_options=""
		linker_options="-bundle -undefined dynamic_lookup"
	else
		compiler_options="-pthread"
		linker_options="-shared"
	fi

	local -x CPP="${_PYTHON_TOOLCHAIN_FUNCS_CPP}"
	local -x CC="${_PYTHON_TOOLCHAIN_FUNCS_CC}${compiler_options:+ }${compiler_options}"
	local -x CXX="${_PYTHON_TOOLCHAIN_FUNCS_CXX}${compiler_options:+ }${compiler_options}"
	local -x AR="${_PYTHON_TOOLCHAIN_FUNCS_AR}"
	local -x LDSHARED="${_PYTHON_TOOLCHAIN_FUNCS_CC}${compiler_options:+ }${compiler_options}${linker_options:+ }${linker_options}"
	local -x LDCXXSHARED="${_PYTHON_TOOLCHAIN_FUNCS_CXX}${compiler_options:+ }${compiler_options}${linker_options:+ }${linker_options}"

	if [[ "${verbose_executables}" == "1" ]]; then
		mkdir -p "${T}/verbose_executables"

		for variable in CPP CC CXX AR LDSHARED LDCXXSHARED; do
			file="${!variable%% *}"
			cat << EOF > "${T}/verbose_executables/${file}"
#!${EPREFIX}/bin/bash

export PATH="\${PATH#${T}/verbose_executables:}"
echo "${file}" "\$@"
exec "$(type -p "${file}")" "\$@"
EOF
			chmod +x "${T}/verbose_executables/${file}"
		done

		local -x PATH="${T}/verbose_executables:${PATH}"
	fi

	"$@"
}

_PYTHON_SHEBANG_BASE_PART_REGEX='^#![[:space:]]*([^[:space:]]*/usr/bin/env[[:space:]]+)?([^[:space:]]*/)?(jython|pypy-python|python)'

# @FUNCTION: python_convert_shebangs
# @USAGE: [-q|--quiet] [-r|--recursive] [-x|--only-executables] [--] <Python_ABI|Python_version> <file|directory> [files|directories]
# @DESCRIPTION:
# Convert shebangs in specified files. Directories can be specified only with --recursive option.
python_convert_shebangs() {
	_python_check_python_pkg_setup_execution

	local argument file files=() only_executables="0" python_interpreter quiet="0" recursive="0" shebangs_converted="0"

	while (($#)); do
		case "$1" in
			-r|--recursive)
				recursive="1"
				;;
			-q|--quiet)
				quiet="1"
				;;
			-x|--only-executables)
				only_executables="1"
				;;
			--)
				shift
				break
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				break
				;;
		esac
		shift
	done

	if [[ "$#" -eq 0 ]]; then
		die "${FUNCNAME}(): Missing Python version and files or directories"
	elif [[ "$#" -eq 1 ]]; then
		die "${FUNCNAME}(): Missing files or directories"
	fi

	if [[ -n "$(_python_get_implementation --ignore-invalid "$1")" ]]; then
		python_interpreter="$(PYTHON "$1")"
	else
		python_interpreter="python$1"
	fi
	shift

	for argument in "$@"; do
		if [[ ! -e "${argument}" ]]; then
			die "${FUNCNAME}(): '${argument}' does not exist"
		elif [[ -f "${argument}" ]]; then
			files+=("${argument}")
		elif [[ -d "${argument}" ]]; then
			if [[ "${recursive}" == "1" ]]; then
				while IFS="" read -d "" -r file; do
					files+=("${file}")
				done < <(find "${argument}" $([[ "${only_executables}" == "1" ]] && echo -perm /111) -type f -print0)
			else
				die "${FUNCNAME}(): '${argument}' is not a regular file"
			fi
		else
			die "${FUNCNAME}(): '${argument}' is not a regular file or a directory"
		fi
	done

	for file in "${files[@]}"; do
		file="${file#./}"
		[[ "${only_executables}" == "1" && ! -x "${file}" ]] && continue

		if [[ "$(head -n1 "${file}")" =~ ${_PYTHON_SHEBANG_BASE_PART_REGEX} ]]; then
			[[ "$(sed -ne "2p" "${file}")" =~ ^"# Gentoo '".*"' wrapper script generated by python_generate_wrapper_scripts()"$ ]] && continue

			shebangs_converted="1"

			if [[ "${quiet}" == "0" ]]; then
				einfo "Converting shebang in '${file}'"
			fi

			sed -e "1s:^#![[:space:]]*\([^[:space:]]*/usr/bin/env[[:space:]]\)\?[[:space:]]*\([^[:space:]]*/\)\?\(jython\|pypy-python\|python\)\([[:digit:]]\+\(\.[[:digit:]]\+\)\?\)\?\(\$\|[[:space:]].*\):#!\1\2${python_interpreter}\6:" -i "${file}" || die "Conversion of shebang in '${file}' failed"
		fi
	done

	if [[ "${shebangs_converted}" == "0" ]]; then
		die "${FUNCNAME}(): Python scripts not found"
	fi
}

# @FUNCTION: python_clean_py-compile_files
# @USAGE: [-q|--quiet]
# @DESCRIPTION:
# Clean py-compile files to disable byte-compilation.
python_clean_py-compile_files() {
	_python_check_python_pkg_setup_execution

	local file files=() quiet="0"

	while (($#)); do
		case "$1" in
			-q|--quiet)
				quiet="1"
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				die "${FUNCNAME}(): Invalid usage"
				;;
		esac
		shift
	done

	while IFS="" read -d "" -r file; do
		files+=("${file#./}")
	done < <(find -name py-compile -type f -print0)

	for file in "${files[@]}"; do
		if [[ "${quiet}" == "0" ]]; then
			einfo "Cleaning '${file}' file"
		fi
		echo "#!/bin/sh" > "${file}"
	done
}

# @FUNCTION: python_clean_installation_image
# @USAGE: [-q|--quiet]
# @DESCRIPTION:
# Delete needless files in installation image.
#
# This function can be used only in src_install() phase.
python_clean_installation_image() {
	if [[ "${EBUILD_PHASE}" != "install" ]]; then
		die "${FUNCNAME}() can be used only in src_install() phase"
	fi

	_python_check_python_pkg_setup_execution
	_python_initialize_prefix_variables

	local file files=() quiet="0"

	while (($#)); do
		case "$1" in
			-q|--quiet)
				quiet="1"
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				die "${FUNCNAME}(): Invalid usage"
				;;
		esac
		shift
	done

	while IFS="" read -d "" -r file; do
		files+=("${file}")
	done < <(find "${ED}" "(" -name "*.py[co]" -o -name "*\$py.class" ")" -type f -print0)

	if [[ "${#files[@]}" -gt 0 ]]; then
		if [[ "${quiet}" == "0" ]]; then
			ewarn "Deleting byte-compiled Python modules needlessly generated by build system:"
		fi
		for file in "${files[@]}"; do
			if [[ "${quiet}" == "0" ]]; then
				ewarn " ${file}"
			fi
			rm -f "${file}"

			# Delete empty __pycache__ directories.
			if [[ "${file%/*}" == *"/__pycache__" ]]; then
				rmdir "${file%/*}" 2> /dev/null
			fi
		done
	fi

	python_clean_sitedirs() {
		if [[ -d "${ED}$(python_get_sitedir)" ]]; then
			find "${ED}$(python_get_sitedir)" "(" -name "*.c" -o -name "*.h" -o -name "*.la" ")" -type f -print0 | xargs -0 rm -f
		fi
	}
	if _python_abi_type multiple; then
		python_execute_function -q python_clean_sitedirs
	else
		python_clean_sitedirs
	fi

	unset -f python_clean_sitedirs
}

# ========================================================================================================================
# ============ FUNCTIONS FOR EBUILDS SETTING PYTHON_ABI_TYPE="single" OR PYTHON_ABI_TYPE="multiple" VARIABLE =============
# ========================================================================================================================

# @ECLASS-VARIABLE: PYTHON_TESTS_RESTRICTED_ABIS
# @DESCRIPTION:
# Space-separated list of Python ABIs patterns. Testing with Python ABIs matching any Python ABIs
# patterns specified in this list is skipped.

# @ECLASS-VARIABLE: PYTHON_TESTS_FAILURES_TOLERANT_ABIS
# @DESCRIPTION:
# Space-separated list of Python ABIs patterns. Failures of tests with Python ABIs matching any
# Python ABIs patterns specified in this list are ignored.

# @ECLASS-VARIABLE: PYTHON_EXPORT_PHASE_FUNCTIONS
# @DESCRIPTION:
# Set this to export phase functions for the following ebuild phases:
# src_prepare(), src_configure(), src_compile(), src_test(), src_install().
if ! has "${EAPI:-0}" 0 1; then
	python_src_prepare() {
		if [[ "${EBUILD_PHASE}" != "prepare" ]]; then
			die "${FUNCNAME}() can be used only in src_prepare() phase"
		fi

		if ! _python_abi_type single && ! _python_abi_type multiple; then
			die "${FUNCNAME}() can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"single\" or PYTHON_ABI_TYPE=\"multiple\" variable"
		fi

		_python_check_python_pkg_setup_execution

		if [[ "$#" -ne 0 ]]; then
			die "${FUNCNAME}() does not accept arguments"
		fi

		if _python_abi_type multiple; then
			python_copy_sources
		fi
	}

	for python_default_function in src_configure src_compile src_test; do
		eval "python_${python_default_function}() {
			if [[ \"\${EBUILD_PHASE}\" != \"${python_default_function#src_}\" ]]; then
				die \"\${FUNCNAME}() can be used only in ${python_default_function}() phase\"
			fi

			if ! _python_abi_type single && ! _python_abi_type multiple; then
				die \"\${FUNCNAME}() can not be used in ebuilds not setting PYTHON_ABI_TYPE=\\\"single\\\" or PYTHON_ABI_TYPE=\\\"multiple\\\" variable\"
			fi

			_python_check_python_pkg_setup_execution

			if _python_abi_type multiple; then
				python_execute_function -d -s -- \"\$@\"
			else
				python_execute_function -d -- \"\$@\"
			fi
		}"
	done
	unset python_default_function

	python_src_install() {
		if [[ "${EBUILD_PHASE}" != "install" ]]; then
			die "${FUNCNAME}() can be used only in src_install() phase"
		fi

		if ! _python_abi_type single && ! _python_abi_type multiple; then
			die "${FUNCNAME}() can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"single\" or PYTHON_ABI_TYPE=\"multiple\" variable"
		fi

		_python_check_python_pkg_setup_execution

		if _python_abi_type multiple; then
			if has "${EAPI:-0}" 2 3; then
				python_execute_function -d -s -- "$@"
			else
				python_installation() {
					python_execute ${MAKE:-make} ${MAKEOPTS} ${EXTRA_EMAKE} DESTDIR="${T}/images/${PYTHON_ABI}" install "$@"
				}
				python_execute_function -s python_installation "$@"
				unset -f python_installation

				python_merge_intermediate_installation_images "${T}/images"
			fi
		else
			python_execute_function -d -- "$@"
		fi
	}

	if [[ -n "${PYTHON_EXPORT_PHASE_FUNCTIONS}" ]]; then
		EXPORT_FUNCTIONS src_prepare src_configure src_compile src_test src_install
	fi
fi

_python_prepare_flags() {
	local array=() deleted_flag element flags new_value old_flag old_value operator pattern prefix variable

	for variable in CPPFLAGS CFLAGS CXXFLAGS LDFLAGS; do
		eval "_PYTHON_SAVED_${variable}=\"\${!variable}\""
		for prefix in PYTHON_USER_ PYTHON_; do
			if [[ "$(declare -p ${prefix}${variable} 2> /dev/null)" == "declare -a ${prefix}${variable}="* ]]; then
				eval "array=(\"\${${prefix}${variable}[@]}\")"
				for element in "${array[@]}"; do
					if [[ "${element}" =~ ^${_PYTHON_ABI_PATTERN_REGEX}\ (\+|-)\ .+ ]]; then
						pattern="${element%% *}"
						element="${element#* }"
						operator="${element%% *}"
						flags="${element#* }"
						if _python_check_python_abi_matching "${PYTHON_ABI}" "${pattern}"; then
							if [[ "${operator}" == "+" ]]; then
								eval "export ${variable}+=\"\${variable:+ }${flags}\""
							elif [[ "${operator}" == "-" ]]; then
								flags="${flags// /$'\n'}"
								old_value="${!variable// /$'\n'}"
								new_value=""
								while read -r old_flag; do
									while read -r deleted_flag; do
										if [[ "${old_flag}" == ${deleted_flag} ]]; then
											continue 2
										fi
									done <<< "${flags}"
									new_value+="${new_value:+ }${old_flag}"
								done <<< "${old_value}"
								eval "export ${variable}=\"\${new_value}\""
							fi
						fi
					else
						die "Element '${element}' of ${prefix}${variable} array has invalid syntax"
					fi
				done
			elif [[ -n "$(declare -p ${prefix}${variable} 2> /dev/null)" ]]; then
				die "${prefix}${variable} should be indexed array"
			fi
		done
	done
}

_python_restore_flags() {
	local variable

	for variable in CPPFLAGS CFLAGS CXXFLAGS LDFLAGS; do
		eval "${variable}=\"\${_PYTHON_SAVED_${variable}}\""
		unset _PYTHON_SAVED_${variable}
	done
}

# @FUNCTION: python_execute_function
# @USAGE: [--action-message message] [-d|--default-function] [--failure-message message] [-f|--final-ABI] [--nonfatal] [-q|--quiet] [-s|--separate-build-dirs] [--source-dir source_directory] [--] <function> [arguments]
# @DESCRIPTION:
# Execute specified function for each value of PYTHON_ABIS, optionally passing additional
# arguments. The specified function can use PYTHON_ABI and BUILDDIR variables.
python_execute_function() {
	if ! _python_abi_type single && ! _python_abi_type multiple; then
		die "${FUNCNAME}() can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"single\" or PYTHON_ABI_TYPE=\"multiple\" variable"
	fi

	_python_check_python_pkg_setup_execution
	_python_set_color_variables

	local PYTHON_ABI
	local -A _python=(
		[action]=
		[action_message]=
		[action_message_template]=
		[default_function]="0"
		[exit_status]=
		[failure_message]=
		[failure_message_template]=
		[final_ABI]="0"
		[function]=
		[iterated_PYTHON_ABIS]=
		[nonfatal]="0"
		[previous_directory]=
		[previous_directory_stack]=
		[previous_directory_stack_length]=
		[quiet]="0"
		[separate_build_dirs]="0"
		[source_dir]=
	)

	while (($#)); do
		case "$1" in
			--action-message)
				_python[action_message_template]="$2"
				shift
				;;
			-d|--default-function)
				_python[default_function]="1"
				;;
			--failure-message)
				_python[failure_message_template]="$2"
				shift
				;;
			-f|--final-ABI)
				_python[final_ABI]="1"
				;;
			--nonfatal)
				_python[nonfatal]="1"
				;;
			-q|--quiet)
				_python[quiet]="1"
				;;
			-s|--separate-build-dirs)
				_python[separate_build_dirs]="1"
				;;
			--source-dir)
				_python[source_dir]="$2"
				shift
				;;
			--)
				shift
				break
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				break
				;;
		esac
		shift
	done

	if ! _python_abi_type multiple && [[ "${_python[final_ABI]}" == "1" ]]; then
		die "${FUNCNAME}(): '--final-ABI' option can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"multiple\" variable"
	fi

	if ! _python_abi_type multiple && [[ "${_python[separate_build_dirs]}" == "1" ]]; then
		die "${FUNCNAME}(): '--separate-build-dirs' option can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"multiple\" variable"
	fi

	if ! _python_abi_type multiple && [[ -n "${_python[source_dir]}" ]]; then
		die "${FUNCNAME}(): '--source-dir' option can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"multiple\" variable"
	fi

	if [[ -n "${_python[source_dir]}" && "${_python[separate_build_dirs]}" == "0" ]]; then
		die "${FUNCNAME}(): '--source-dir' option can be specified only with '--separate-build-dirs' option"
	fi

	if [[ "${_python[default_function]}" == "0" ]]; then
		if [[ "$#" -eq 0 ]]; then
			die "${FUNCNAME}(): Missing function name"
		fi
		_python[function]="$1"
		shift

		if [[ -z "$(type -t "${_python[function]}")" ]]; then
			die "${FUNCNAME}(): '${_python[function]}' function is not defined"
		fi
	else
		if has "${EAPI:-0}" 0 1; then
			die "${FUNCNAME}(): '--default-function' option can not be used in EAPI=\"${EAPI}\""
		fi

		if [[ "${EBUILD_PHASE}" == "configure" ]]; then
			if has "${EAPI}" 2 3; then
				python_default_function() {
					econf "$@"
				}
			else
				python_default_function() {
					nonfatal econf "$@"
				}
			fi
		elif [[ "${EBUILD_PHASE}" == "compile" ]]; then
			python_default_function() {
				python_execute ${MAKE:-make} ${MAKEOPTS} ${EXTRA_EMAKE} "$@"
			}
		elif [[ "${EBUILD_PHASE}" == "test" ]]; then
			python_default_function() {
				local options=()
				if has "${EAPI}" 2 3 4 4-python; then
					options+=("-j1")
				fi
				if make -n check &> /dev/null; then
					python_execute ${MAKE:-make} ${MAKEOPTS} ${EXTRA_EMAKE} "${options[@]}" check "$@"
				elif make -n test &> /dev/null; then
					python_execute ${MAKE:-make} ${MAKEOPTS} ${EXTRA_EMAKE} "${options[@]}" test "$@"
				fi
			}
		elif [[ "${EBUILD_PHASE}" == "install" ]]; then
			python_default_function() {
				python_execute ${MAKE:-make} ${MAKEOPTS} ${EXTRA_EMAKE} DESTDIR="${D}" install "$@"
			}
		else
			die "${FUNCNAME}(): '--default-function' option can not be used in this ebuild phase"
		fi
		_python[function]="python_default_function"
	fi

	# Ensure that python_execute_function() can not be directly or indirectly called by python_execute_function().
	if _python_abi-specific_local_scope; then
		die "${FUNCNAME}(): Invalid call stack"
	fi

	[[ "${EBUILD_PHASE}" == "setup" ]] && _python[action]="Setting up"
	[[ "${EBUILD_PHASE}" == "unpack" ]] && _python[action]="Unpacking"
	[[ "${EBUILD_PHASE}" == "prepare" ]] && _python[action]="Preparation"
	[[ "${EBUILD_PHASE}" == "configure" ]] && _python[action]="Configuration"
	[[ "${EBUILD_PHASE}" == "compile" ]] && _python[action]="Building"
	[[ "${EBUILD_PHASE}" == "test" ]] && _python[action]="Testing"
	[[ "${EBUILD_PHASE}" == "install" ]] && _python[action]="Installation"
	[[ "${EBUILD_PHASE}" == "preinst" ]] && _python[action]="Preinstallation"
	[[ "${EBUILD_PHASE}" == "postinst" ]] && _python[action]="Postinstallation"
	[[ "${EBUILD_PHASE}" == "prerm" ]] && _python[action]="Preuninstallation"
	[[ "${EBUILD_PHASE}" == "postrm" ]] && _python[action]="Postuninstallation"

	if has "${EAPI:-0}" 0 1 2 3 4 5 && _python_abi_type multiple; then
		_python_calculate_PYTHON_ABIS
	fi
	if _python_abi_type single; then
		_python[iterated_PYTHON_ABIS]="${PYTHON_SINGLE_ABI}"
	else
		if [[ "${_python[final_ABI]}" == "1" ]]; then
			_python[iterated_PYTHON_ABIS]="$(PYTHON -f --ABI)"
		else
			_python[iterated_PYTHON_ABIS]="${PYTHON_ABIS}"
		fi
	fi
	for PYTHON_ABI in ${_python[iterated_PYTHON_ABIS]}; do
		if [[ "${EBUILD_PHASE}" == "test" ]] && _python_check_python_abi_matching --patterns-list "${PYTHON_ABI}" "${PYTHON_TESTS_RESTRICTED_ABIS}"; then
			if [[ "${_python[quiet]}" == "0" ]]; then
				echo " ${_GREEN}*${_NORMAL} ${_BLUE}Testing of ${CATEGORY}/${PF} with $(python_get_implementation_and_version) skipped${_NORMAL}"
			fi
			continue
		fi

		_python_prepare_flags

		if [[ "${_python[quiet]}" == "0" ]]; then
			if [[ -n "${_python[action_message_template]}" ]]; then
				eval "_python[action_message]=\"${_python[action_message_template]}\""
			else
				_python[action_message]="${_python[action]} of ${CATEGORY}/${PF} with $(python_get_implementation_and_version)..."
			fi
			echo " ${_GREEN}*${_NORMAL} ${_BLUE}${_python[action_message]}${_NORMAL}"
		fi

		if [[ "${_python[separate_build_dirs]}" == "1" ]]; then
			if [[ -n "${_python[source_dir]}" ]]; then
				export BUILDDIR="$(pwd)/${_python[source_dir]}-${PYTHON_ABI}"
			else
				export BUILDDIR="$(pwd)-${PYTHON_ABI}"
			fi
			pushd "${BUILDDIR}" > /dev/null || die "pushd failed"
		else
			export BUILDDIR="$(pwd)"
		fi

		_python[previous_directory]="$(pwd)"
		_python[previous_directory_stack]="$(dirs -p)"
		_python[previous_directory_stack_length]="$(dirs -p | wc -l)"

		if [[ "${EBUILD_PHASE}" == "test" ]] && ! has "${EAPI}" 0 1 2 3 && _python_check_python_abi_matching --patterns-list "${PYTHON_ABI}" "${PYTHON_TESTS_FAILURES_TOLERANT_ABIS}"; then
			EPYTHON="$(PYTHON)" nonfatal "${_python[function]}" "$@"
		else
			EPYTHON="$(PYTHON)" "${_python[function]}" "$@"
		fi

		_python[exit_status]="$?"

		_python_restore_flags

		if [[ "${_python[exit_status]}" -ne 0 ]]; then
			if [[ -n "${_python[failure_message_template]}" ]]; then
				eval "_python[failure_message]=\"${_python[failure_message_template]}\""
			else
				_python[failure_message]="${_python[action]} failed with $(python_get_implementation_and_version) in ${_python[function]}() function"
			fi

			if [[ "${_python[nonfatal]}" == "1" ]]; then
				if [[ "${_python[quiet]}" == "0" ]]; then
					ewarn "${_python[failure_message]}"
				fi
			elif [[ "${_python[final_ABI]}" == "0" && "${EBUILD_PHASE}" == "test" ]] && _python_check_python_abi_matching --patterns-list "${PYTHON_ABI}" "${PYTHON_TESTS_FAILURES_TOLERANT_ABIS}"; then
				if [[ "${_python[quiet]}" == "0" ]]; then
					ewarn "${_python[failure_message]}"
				fi
			else
				die "${_python[failure_message]}"
			fi
		fi

		# Ensure that directory stack has not been decreased.
		if [[ "$(dirs -p | wc -l)" -lt "${_python[previous_directory_stack_length]}" ]]; then
			die "Directory stack decreased illegally"
		fi

		# Avoid side effects of earlier returning from the specified function.
		while [[ "$(dirs -p | wc -l)" -gt "${_python[previous_directory_stack_length]}" ]]; do
			popd > /dev/null || die "popd failed"
		done

		# Ensure that the bottom part of directory stack has not been changed. Restore
		# previous directory (from before running of the specified function) before
		# comparison of directory stacks to avoid mismatch of directory stacks after
		# potential using of 'cd' to change current directory. Restoration of previous
		# directory allows to safely use 'cd' to change current directory in the
		# specified function without changing it back to original directory.
		cd "${_python[previous_directory]}"
		if [[ "$(dirs -p)" != "${_python[previous_directory_stack]}" ]]; then
			die "Directory stack changed illegally"
		fi

		if [[ "${_python[separate_build_dirs]}" == "1" ]]; then
			popd > /dev/null || die "popd failed"
		fi
		unset BUILDDIR
	done

	if [[ "${_python[default_function]}" == "1" ]]; then
		unset -f python_default_function
	fi
}

# ========================================================================================================================
# ========================== FUNCTIONS FOR EBUILDS SETTING PYTHON_ABI_TYPE="multiple" VARIABLE ===========================
# ========================================================================================================================

if has "${EAPI:-0}" 0 1 2 3 4 5; then
	unset PYTHON_ABIS
fi

_python_calculate_PYTHON_ABIS() {
	if ! has "${EAPI:-0}" 0 1 2 3 4 5; then
		die "${FUNCNAME}() can not be used in EAPI=\"${EAPI}\""
	fi

	if ! _python_abi_type multiple; then
		die "${FUNCNAME}() can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"multiple\" variable"
	fi

	_python_initial_sanity_checks

	if has "${EAPI:-0}" 0 1 2 3 || { has "${EAPI:-0}" 4 5 && has "${PYTHON_ECLASS_API}" 0; }; then
		if [[ -z "${PYTHON_RESTRICTED_ABIS}" && -n "${RESTRICT_PYTHON_ABIS}" ]]; then
			PYTHON_RESTRICTED_ABIS="${RESTRICT_PYTHON_ABIS}"
		fi
	else
		if [[ -n "${SUPPORT_PYTHON_ABIS}" ]]; then
			eerror "Use PYTHON_ABI_TYPE=\"multiple\" variable instead of SUPPORT_PYTHON_ABIS variable."
			die "SUPPORT_PYTHON_ABIS variable is banned"
		fi
		if [[ -n "${RESTRICT_PYTHON_ABIS}" ]]; then
			eerror "Use PYTHON_RESTRICTED_ABIS variable instead of RESTRICT_PYTHON_ABIS variable."
			die "RESTRICT_PYTHON_ABIS variable is banned"
		fi
	fi

	if [[ "$(declare -p PYTHON_ABIS 2> /dev/null)" != "declare -x PYTHON_ABIS="* ]]; then
		local PYTHON_ABI

		if [[ "$(declare -p USE_PYTHON 2> /dev/null)" == "declare -x USE_PYTHON="* ]]; then
			local cpython_enabled="0"

			if [[ -z "${USE_PYTHON}" ]]; then
				die "USE_PYTHON variable is empty"
			fi

			for PYTHON_ABI in ${USE_PYTHON}; do
				if ! has "${PYTHON_ABI}" "${_PYTHON_GLOBALLY_SUPPORTED_ABIS[@]}"; then
					die "USE_PYTHON variable contains invalid value '${PYTHON_ABI}'"
				fi

				if has "${PYTHON_ABI}" "${_CPYTHON2_GLOBALLY_SUPPORTED_ABIS[@]}" "${_CPYTHON3_GLOBALLY_SUPPORTED_ABIS[@]}"; then
					cpython_enabled="1"
				fi

				if ! _python_check_python_abi_matching --patterns-list "${PYTHON_ABI}" "${PYTHON_RESTRICTED_ABIS}"; then
					export PYTHON_ABIS+="${PYTHON_ABIS:+ }${PYTHON_ABI}"
				fi
			done

			if [[ -z "${PYTHON_ABIS//[${IFS}]/}" ]]; then
				die "USE_PYTHON variable does not enable any Python ABI supported by ${CATEGORY}/${PF}"
			fi

			if [[ "${cpython_enabled}" == "0" ]]; then
				die "USE_PYTHON variable does not enable any CPython ABI"
			fi
		else
			local python_version python2_version python3_version support_python_major_version

			if ! ROOT="/" has_version "dev-lang/python"; then
				die "${FUNCNAME}(): 'dev-lang/python' is not installed"
			fi

			python_version="$("${EPREFIX}/usr/bin/python" -c 'from sys import version_info; print(".".join(str(x) for x in version_info[:2]))')"

			if ROOT="/" has_version "=dev-lang/python-2*"; then
				if [[ "$(readlink "${EPREFIX}/usr/bin/python2")" != "python2."* ]]; then
					die "'${EPREFIX}/usr/bin/python2' is not valid symlink"
				fi

				python2_version="$("${EPREFIX}/usr/bin/python2" -c 'from sys import version_info; print(".".join(str(x) for x in version_info[:2]))')"

				support_python_major_version="0"
				for PYTHON_ABI in "${_CPYTHON2_GLOBALLY_SUPPORTED_ABIS[@]}"; do
					if ! _python_check_python_abi_matching --patterns-list "${PYTHON_ABI}" "${PYTHON_RESTRICTED_ABIS}"; then
						support_python_major_version="1"
						break
					fi
				done
				if [[ "${support_python_major_version}" == "1" ]]; then
					if _python_check_python_abi_matching --patterns-list "${python2_version}" "${PYTHON_RESTRICTED_ABIS}"; then
						die "Active version of CPython 2 is not supported by ${CATEGORY}/${PF}"
					fi
				else
					python2_version=""
				fi
			fi

			if ROOT="/" has_version "=dev-lang/python-3*"; then
				if [[ "$(readlink "${EPREFIX}/usr/bin/python3")" != "python3."* ]]; then
					die "'${EPREFIX}/usr/bin/python3' is not valid symlink"
				fi

				python3_version="$("${EPREFIX}/usr/bin/python3" -c 'from sys import version_info; print(".".join(str(x) for x in version_info[:2]))')"

				support_python_major_version="0"
				for PYTHON_ABI in "${_CPYTHON3_GLOBALLY_SUPPORTED_ABIS[@]}"; do
					if ! _python_check_python_abi_matching --patterns-list "${PYTHON_ABI}" "${PYTHON_RESTRICTED_ABIS}"; then
						support_python_major_version="1"
						break
					fi
				done
				if [[ "${support_python_major_version}" == "1" ]]; then
					if _python_check_python_abi_matching --patterns-list "${python3_version}" "${PYTHON_RESTRICTED_ABIS}"; then
						die "Active version of CPython 3 is not supported by ${CATEGORY}/${PF}"
					fi
				else
					python3_version=""
				fi
			fi

			if [[ -z "${python2_version}" && -z "${python3_version}" ]]; then
				eerror "${CATEGORY}/${PF} requires at least one of the following packages:"
				for PYTHON_ABI in "${_CPYTHON2_GLOBALLY_SUPPORTED_ABIS[@]}" "${_CPYTHON3_GLOBALLY_SUPPORTED_ABIS[@]}"; do
					if ! _python_check_python_abi_matching --patterns-list "${PYTHON_ABI}" "${PYTHON_RESTRICTED_ABIS}"; then
						eerror "    dev-lang/python:${PYTHON_ABI}"
					fi
				done
				die "No supported version of CPython installed"
			fi

			if [[ -n "${python2_version}" && "${python_version}" == "2."* && "${python_version}" != "${python2_version}" ]]; then
				eerror "Python wrapper is configured incorrectly or '${EPREFIX}/usr/bin/python2' symlink"
				eerror "is set incorrectly. Use \`eselect python\` to fix configuration."
				die "Incorrect configuration of Python"
			fi
			if [[ -n "${python3_version}" && "${python_version}" == "3."* && "${python_version}" != "${python3_version}" ]]; then
				eerror "Python wrapper is configured incorrectly or '${EPREFIX}/usr/bin/python3' symlink"
				eerror "is set incorrectly. Use \`eselect python\` to fix configuration."
				die "Incorrect configuration of Python"
			fi

			PYTHON_ABIS="${python2_version} ${python3_version}"
			PYTHON_ABIS="${PYTHON_ABIS# }"
			export PYTHON_ABIS="${PYTHON_ABIS% }"
		fi
	fi

	_python_final_sanity_checks
}

# @FUNCTION: python_copy_sources
# @USAGE: <directory="$(pwd)"> [directory]
# @DESCRIPTION:
# Copy unpacked sources of current package to separate build directory for each Python ABI.
python_copy_sources() {
	if ! _python_abi_type multiple; then
		die "${FUNCNAME}() can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"multiple\" variable"
	fi

	_python_check_python_pkg_setup_execution

	local dir dirs=() PYTHON_ABI

	if [[ "$#" -eq 0 ]]; then
		if [[ "${WORKDIR}" == "$(pwd)" ]]; then
			die "${FUNCNAME}() without arguments can not be used in current directory"
		fi
		dirs=("${S%/}")
	else
		dirs=("$@")
	fi

	if has "${EAPI:-0}" 0 1 2 3 4 5; then
		_python_calculate_PYTHON_ABIS
	fi
	for PYTHON_ABI in ${PYTHON_ABIS}; do
		for dir in "${dirs[@]}"; do
			cp -pr "${dir}" "${dir}-${PYTHON_ABI}" > /dev/null || die "Copying of sources failed"
		done
	done
}

# @FUNCTION: python_generate_wrapper_scripts
# @USAGE: [-E|--respect-EPYTHON] [-f|--force] [-q|--quiet] [--] <file> [files]
# @DESCRIPTION:
# Generate wrapper scripts. Existing files are overwritten only with --force option.
# If --respect-EPYTHON option is specified, then generated wrapper scripts will
# respect EPYTHON variable at run time.
#
# This function can be used only in src_install() phase.
python_generate_wrapper_scripts() {
	if [[ "${EBUILD_PHASE}" != "install" ]]; then
		die "${FUNCNAME}() can be used only in src_install() phase"
	fi

	if ! _python_abi_type multiple; then
		die "${FUNCNAME}() can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"multiple\" variable"
	fi

	_python_check_python_pkg_setup_execution
	_python_initialize_prefix_variables

	local eselect_python_option file force="0" quiet="0" PYTHON_ABI PYTHON_ABIS_list python2_enabled="0" python3_enabled="0" respect_EPYTHON="0"

	while (($#)); do
		case "$1" in
			-E|--respect-EPYTHON)
				respect_EPYTHON="1"
				;;
			-f|--force)
				force="1"
				;;
			-q|--quiet)
				quiet="1"
				;;
			--)
				shift
				break
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				break
				;;
		esac
		shift
	done

	if [[ "$#" -eq 0 ]]; then
		die "${FUNCNAME}(): Missing arguments"
	fi

	if has "${EAPI:-0}" 0 1 2 3 4 5; then
		_python_calculate_PYTHON_ABIS
	fi
	for PYTHON_ABI in "${_CPYTHON2_GLOBALLY_SUPPORTED_ABIS[@]}"; do
		if has "${PYTHON_ABI}" ${PYTHON_ABIS}; then
			python2_enabled="1"
		fi
	done
	for PYTHON_ABI in "${_CPYTHON3_GLOBALLY_SUPPORTED_ABIS[@]}"; do
		if has "${PYTHON_ABI}" ${PYTHON_ABIS}; then
			python3_enabled="1"
		fi
	done

	if [[ "${python2_enabled}" == "1" && "${python3_enabled}" == "1" ]]; then
		eselect_python_option=
	elif [[ "${python2_enabled}" == "1" && "${python3_enabled}" == "0" ]]; then
		eselect_python_option="--python2"
	elif [[ "${python2_enabled}" == "0" && "${python3_enabled}" == "1" ]]; then
		eselect_python_option="--python3"
	else
		die "${FUNCNAME}(): Unsupported environment"
	fi

	PYTHON_ABIS_list="$("$(PYTHON -f)" -c "print(', '.join('\"%s\"' % x for x in reversed('${PYTHON_ABIS}'.split())))")"

	for file in "$@"; do
		if [[ -f "${file}" && "${force}" == "0" ]]; then
			die "${FUNCNAME}(): '${file}' already exists"
		fi

		if [[ "${quiet}" == "0" ]]; then
			einfo "Generating '${file#${ED%/}}' wrapper script"
		fi

		cat << EOF > "${file}"
#!/usr/bin/env python
# Gentoo '${file##*/}' wrapper script generated by python_generate_wrapper_scripts()

import os
import re
import subprocess
import sys

cpython_ABI_re = re.compile(r"^(\d+\.\d+)$")
jython_ABI_re = re.compile(r"^(\d+\.\d+)-jython$")
pypy_ABI_re = re.compile(r"^(\d+\.\d+)-pypy$")
cpython_interpreter_re = re.compile(r"^python(\d+\.\d+)$")
jython_interpreter_re = re.compile(r"^jython(\d+\.\d+)$")
pypy_interpreter_re = re.compile(r"^pypy-python(\d+\.\d+)$")
cpython_shebang_re = re.compile(r"^#![ \t]*(?:${EPREFIX}/usr/bin/python|(?:${EPREFIX})?/usr/bin/env[ \t]+(?:${EPREFIX}/usr/bin/)?python)")
python_shebang_options_re = re.compile(r"^#![ \t]*${EPREFIX}/usr/bin/(?:jython|pypy-python|python)(?:\d+(?:\.\d+)?)?[ \t]+(-\S)")
python_verification_output_re = re.compile("^GENTOO_PYTHON_TARGET_SCRIPT_PATH supported\n$")

def get_PYTHON_ABI(python_interpreter):
	cpython_matched = cpython_interpreter_re.match(python_interpreter)
	jython_matched = jython_interpreter_re.match(python_interpreter)
	pypy_matched = pypy_interpreter_re.match(python_interpreter)
	if cpython_matched is not None:
		PYTHON_ABI = cpython_matched.group(1)
	elif jython_matched is not None:
		PYTHON_ABI = jython_matched.group(1) + "-jython"
	elif pypy_matched is not None:
		PYTHON_ABI = pypy_matched.group(1) + "-pypy"
	else:
		PYTHON_ABI = None
	return PYTHON_ABI

def get_python_interpreter(PYTHON_ABI):
	cpython_matched = cpython_ABI_re.match(PYTHON_ABI)
	jython_matched = jython_ABI_re.match(PYTHON_ABI)
	pypy_matched = pypy_ABI_re.match(PYTHON_ABI)
	if cpython_matched is not None:
		python_interpreter = "python" + cpython_matched.group(1)
	elif jython_matched is not None:
		python_interpreter = "jython" + jython_matched.group(1)
	elif pypy_matched is not None:
		python_interpreter = "pypy" + pypy_matched.group(1)
	else:
		python_interpreter = None
	return python_interpreter

EOF
		if [[ "$?" != "0" ]]; then
			die "${FUNCNAME}(): Generation of '$1' failed"
		fi
		if [[ "${respect_EPYTHON}" == "1" ]]; then
			cat << EOF >> "${file}"
python_interpreter = os.environ.get("EPYTHON")
if python_interpreter:
	PYTHON_ABI = get_PYTHON_ABI(python_interpreter)
	if PYTHON_ABI is None:
		sys.stderr.write("%s: EPYTHON variable has unrecognized value '%s'\n" % (sys.argv[0], python_interpreter))
		sys.exit(1)
else:
	try:
		environment = os.environ.copy()
		environment["ROOT"] = "/"
		eselect_process = subprocess.Popen(["${EPREFIX}/usr/bin/eselect", "python", "show"${eselect_python_option:+, $(echo "\"")}${eselect_python_option}${eselect_python_option:+$(echo "\"")}], env=environment, stdout=subprocess.PIPE)
		if eselect_process.wait() != 0:
			raise ValueError
	except (OSError, ValueError):
		sys.stderr.write("%s: Execution of 'eselect python show${eselect_python_option:+ }${eselect_python_option}' failed\n" % sys.argv[0])
		sys.exit(1)

	python_interpreter = eselect_process.stdout.read()
	if not isinstance(python_interpreter, str):
		# Python 3
		python_interpreter = python_interpreter.decode()
	python_interpreter = python_interpreter.rstrip("\n")

	PYTHON_ABI = get_PYTHON_ABI(python_interpreter)
	if PYTHON_ABI is None:
		sys.stderr.write("%s: 'eselect python show${eselect_python_option:+ }${eselect_python_option}' printed unrecognized value '%s'\n" % (sys.argv[0], python_interpreter))
		sys.exit(1)

wrapper_script_path = os.path.realpath(sys.argv[0])
target_executable_path = "%s-%s" % (wrapper_script_path, PYTHON_ABI)
if not os.path.exists(target_executable_path):
	sys.stderr.write("%s: '%s' does not exist\n" % (sys.argv[0], target_executable_path))
	sys.exit(1)
EOF
			if [[ "$?" != "0" ]]; then
				die "${FUNCNAME}(): Generation of '$1' failed"
			fi
		else
			cat << EOF >> "${file}"
try:
	environment = os.environ.copy()
	environment["ROOT"] = "/"
	eselect_process = subprocess.Popen(["${EPREFIX}/usr/bin/eselect", "python", "show"${eselect_python_option:+, $(echo "\"")}${eselect_python_option}${eselect_python_option:+$(echo "\"")}], env=environment, stdout=subprocess.PIPE)
	if eselect_process.wait() != 0:
		raise ValueError
except (OSError, ValueError):
	sys.stderr.write("%s: Execution of 'eselect python show${eselect_python_option:+ }${eselect_python_option}' failed\n" % sys.argv[0])
	sys.exit(1)

python_interpreter = eselect_process.stdout.read()
if not isinstance(python_interpreter, str):
	# Python 3
	python_interpreter = python_interpreter.decode()
python_interpreter = python_interpreter.rstrip("\n")

PYTHON_ABI = get_PYTHON_ABI(python_interpreter)
if PYTHON_ABI is None:
	sys.stderr.write("%s: 'eselect python show${eselect_python_option:+ }${eselect_python_option}' printed unrecognized value '%s'\n" % (sys.argv[0], python_interpreter))
	sys.exit(1)

wrapper_script_path = os.path.realpath(sys.argv[0])
for PYTHON_ABI in [PYTHON_ABI, ${PYTHON_ABIS_list}]:
	target_executable_path = "%s-%s" % (wrapper_script_path, PYTHON_ABI)
	if os.path.exists(target_executable_path):
		break
else:
	sys.stderr.write("%s: No target script exists for '%s'\n" % (sys.argv[0], wrapper_script_path))
	sys.exit(1)

python_interpreter = get_python_interpreter(PYTHON_ABI)
if python_interpreter is None:
	sys.stderr.write("%s: Unrecognized Python ABI '%s'\n" % (sys.argv[0], PYTHON_ABI))
	sys.exit(1)
EOF
			if [[ "$?" != "0" ]]; then
				die "${FUNCNAME}(): Generation of '$1' failed"
			fi
		fi
		cat << EOF >> "${file}"

target_executable = open(target_executable_path, "rb")
target_executable_first_line = target_executable.readline()
target_executable.close()
if not isinstance(target_executable_first_line, str):
	# Python 3
	target_executable_first_line = target_executable_first_line.decode("utf_8", "replace")

options = []
python_shebang_options_matched = python_shebang_options_re.match(target_executable_first_line)
if python_shebang_options_matched is not None:
	options = [python_shebang_options_matched.group(1)]

cpython_shebang_matched = cpython_shebang_re.match(target_executable_first_line)

if cpython_shebang_matched is not None:
	try:
		python_interpreter_path = "${EPREFIX}/usr/bin/%s" % python_interpreter
		os.environ["GENTOO_PYTHON_TARGET_SCRIPT_PATH_VERIFICATION"] = "1"
		python_verification_process = subprocess.Popen([python_interpreter_path, "-c", "pass"], stdout=subprocess.PIPE)
		del os.environ["GENTOO_PYTHON_TARGET_SCRIPT_PATH_VERIFICATION"]
		if python_verification_process.wait() != 0:
			raise ValueError

		python_verification_output = python_verification_process.stdout.read()
		if not isinstance(python_verification_output, str):
			# Python 3
			python_verification_output = python_verification_output.decode()

		if not python_verification_output_re.match(python_verification_output):
			raise ValueError

		if cpython_interpreter_re.match(python_interpreter) is not None:
			os.environ["GENTOO_PYTHON_PROCESS_NAME"] = os.path.basename(sys.argv[0])
			os.environ["GENTOO_PYTHON_WRAPPER_SCRIPT_PATH"] = sys.argv[0]
			os.environ["GENTOO_PYTHON_TARGET_SCRIPT_PATH"] = target_executable_path

		if hasattr(os, "execv"):
			os.execv(python_interpreter_path, [python_interpreter_path] + options + sys.argv)
		else:
			sys.exit(subprocess.Popen([python_interpreter_path] + options + sys.argv).wait())
	except (KeyboardInterrupt, SystemExit):
		raise
	except:
		pass
	for variable in ("GENTOO_PYTHON_PROCESS_NAME", "GENTOO_PYTHON_WRAPPER_SCRIPT_PATH", "GENTOO_PYTHON_TARGET_SCRIPT_PATH", "GENTOO_PYTHON_TARGET_SCRIPT_PATH_VERIFICATION"):
		if variable in os.environ:
			del os.environ[variable]

if hasattr(os, "execv"):
	os.execv(target_executable_path, sys.argv)
else:
	sys.exit(subprocess.Popen([target_executable_path] + sys.argv[1:]).wait())
EOF
		if [[ "$?" != "0" ]]; then
			die "${FUNCNAME}(): Generation of '$1' failed"
		fi
		fperms +x "${file#${ED%/}}" || die "fperms '${file}' failed"
	done
}

# @ECLASS-VARIABLE: PYTHON_VERSIONED_SCRIPTS
# @DESCRIPTION:
# Array of regular expressions of paths to versioned Python scripts.
# Python scripts in /usr/bin and /usr/sbin are versioned by default.

# @ECLASS-VARIABLE: PYTHON_VERSIONED_EXECUTABLES
# @DESCRIPTION:
# Array of regular expressions of paths to versioned executables (including Python scripts).

# @ECLASS-VARIABLE: PYTHON_NONVERSIONED_EXECUTABLES
# @DESCRIPTION:
# Array of regular expressions of paths to nonversioned executables (including Python scripts).

# @FUNCTION: python_merge_intermediate_installation_images
# @USAGE: [-q|--quiet] [--] <intermediate_installation_images_directory>
# @DESCRIPTION:
# Merge intermediate installation images into installation image.
#
# This function can be used only in src_install() phase.
python_merge_intermediate_installation_images() {
	if [[ "${EBUILD_PHASE}" != "install" ]]; then
		die "${FUNCNAME}() can be used only in src_install() phase"
	fi

	if ! _python_abi_type multiple; then
		die "${FUNCNAME}() can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"multiple\" variable"
	fi

	_python_check_python_pkg_setup_execution
	_python_initialize_prefix_variables

	local absolute_file b file files=() intermediate_installation_images_directory PYTHON_ABI quiet="0" regex shebang version_executable wrapper_scripts=() wrapper_scripts_set=()

	while (($#)); do
		case "$1" in
			-q|--quiet)
				quiet="1"
				;;
			--)
				shift
				break
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				break
				;;
		esac
		shift
	done

	if [[ "$#" -ne 1 ]]; then
		die "${FUNCNAME}() requires 1 argument"
	fi

	intermediate_installation_images_directory="$1"

	if [[ ! -d "${intermediate_installation_images_directory}" ]]; then
		die "${FUNCNAME}(): Intermediate installation images directory '${intermediate_installation_images_directory}' does not exist"
	fi

	if has "${EAPI:-0}" 0 1 2 3 4 5; then
		_python_calculate_PYTHON_ABIS
	fi
	if [[ "$(PYTHON -f --ABI)" == 3.* ]]; then
		b="b"
	fi

	while IFS="" read -d "" -r file; do
		files+=("${file}")
	done < <("$(PYTHON -f)" -c \
"import os
import sys

if hasattr(sys.stdout, 'buffer'):
	# Python 3
	stdout = sys.stdout.buffer
else:
	# Python 2
	stdout = sys.stdout

files_set = set()

os.chdir(${b}'${intermediate_installation_images_directory}')

for PYTHON_ABI in ${b}'${PYTHON_ABIS}'.split():
	for root, dirs, files in os.walk(PYTHON_ABI + ${b}'${EPREFIX}'):
		root = root[len(PYTHON_ABI + ${b}'${EPREFIX}')+1:]
		files_set.update(root + ${b}'/' + file for file in files)

for file in sorted(files_set):
	stdout.write(file)
	stdout.write(${b}'\x00')" || die "${FUNCNAME}(): Failure of extraction of files in intermediate installation images")

	for PYTHON_ABI in ${PYTHON_ABIS}; do
		if [[ ! -d "${intermediate_installation_images_directory}/${PYTHON_ABI}" ]]; then
			die "${FUNCNAME}(): Intermediate installation image for Python ABI '${PYTHON_ABI}' does not exist"
		fi

		pushd "${intermediate_installation_images_directory}/${PYTHON_ABI}${EPREFIX}" > /dev/null || die "pushd failed"

		for file in "${files[@]}"; do
			version_executable="0"
			for regex in "/usr/bin/.*" "/usr/sbin/.*" "${PYTHON_VERSIONED_SCRIPTS[@]}"; do
				if [[ "/${file}" =~ ^${regex}$ ]]; then
					version_executable="1"
					break
				fi
			done
			for regex in "${PYTHON_VERSIONED_EXECUTABLES[@]}"; do
				if [[ "/${file}" =~ ^${regex}$ ]]; then
					version_executable="2"
					break
				fi
			done
			if [[ "${version_executable}" != "0" ]]; then
				for regex in "${PYTHON_NONVERSIONED_EXECUTABLES[@]}"; do
					if [[ "/${file}" =~ ^${regex}$ ]]; then
						version_executable="0"
						break
					fi
				done
			fi

			[[ "${version_executable}" == "0" ]] && continue

			if [[ -L "${file}" ]]; then
				absolute_file="$(readlink "${file}")"
				if [[ "${absolute_file}" == /* ]]; then
					absolute_file="${intermediate_installation_images_directory}/${PYTHON_ABI}${EPREFIX}/${absolute_file##/}"
				else
					if [[ "${file}" == */* ]]; then
						absolute_file="${intermediate_installation_images_directory}/${PYTHON_ABI}${EPREFIX}/${file%/*}/${absolute_file}"
					else
						absolute_file="${intermediate_installation_images_directory}/${PYTHON_ABI}${EPREFIX}/${absolute_file}"
					fi
				fi
			else
				absolute_file="${intermediate_installation_images_directory}/${PYTHON_ABI}${EPREFIX}/${file}"
			fi

			[[ ! -x "${absolute_file}" ]] && continue

			shebang="$(head -n1 "${absolute_file}")" || die "Extraction of shebang from '${absolute_file}' failed"

			if [[ "${version_executable}" == "2" ]]; then
				wrapper_scripts+=("${ED}${file}")
			elif [[ "${version_executable}" == "1" ]]; then
				if [[ "${shebang}" =~ ${_PYTHON_SHEBANG_BASE_PART_REGEX}([[:digit:]]+(\.[[:digit:]]+)?)?($|[[:space:]]+) ]]; then
					wrapper_scripts+=("${ED}${file}")
				else
					version_executable="0"
				fi
			fi

			[[ "${version_executable}" == "0" ]] && continue

			if [[ -e "${file}-${PYTHON_ABI}" ]]; then
				die "${FUNCNAME}(): '${EPREFIX}/${file}-${PYTHON_ABI}' already exists"
			fi

			mv "${file}" "${file}-${PYTHON_ABI}" || die "Renaming of '${file}' failed"

			if [[ "${shebang}" =~ ${_PYTHON_SHEBANG_BASE_PART_REGEX}[[:digit:]]*($|[[:space:]]+) ]]; then
				if [[ -L "${file}-${PYTHON_ABI}" ]]; then
					python_convert_shebangs $([[ "${quiet}" == "1" ]] && echo --quiet) "${PYTHON_ABI}" "${absolute_file}"
				else
					python_convert_shebangs $([[ "${quiet}" == "1" ]] && echo --quiet) "${PYTHON_ABI}" "${file}-${PYTHON_ABI}"
				fi
			fi
		done

		popd > /dev/null || die "popd failed"

		if ROOT="/" has_version ">=sys-apps/coreutils-6.9.90"; then
			cp -fr --preserve=all --no-preserve=context "${intermediate_installation_images_directory}/${PYTHON_ABI}/"* "${D}" || die "Merging of intermediate installation image for Python ABI '${PYTHON_ABI} into installation image failed"
		elif ROOT="/" has_version sys-apps/coreutils; then
			cp -fr --preserve=all "${intermediate_installation_images_directory}/${PYTHON_ABI}/"* "${D}" || die "Merging of intermediate installation image for Python ABI '${PYTHON_ABI} into installation image failed"
		else
			cp -fpr "${intermediate_installation_images_directory}/${PYTHON_ABI}/"* "${D}" || die "Merging of intermediate installation image for Python ABI '${PYTHON_ABI} into installation image failed"
		fi
	done

	rm -fr "${intermediate_installation_images_directory}"

	if [[ "${#wrapper_scripts[@]}" -ge 1 ]]; then
		rm -f "${T}/python_wrapper_scripts"

		for file in "${wrapper_scripts[@]}"; do
			echo -n "${file}" >> "${T}/python_wrapper_scripts"
			echo -en "\x00" >> "${T}/python_wrapper_scripts"
		done

		while IFS="" read -d "" -r file; do
			wrapper_scripts_set+=("${file}")
		done < <("$(PYTHON -f)" -c \
"import sys

if hasattr(sys.stdout, 'buffer'):
	# Python 3
	stdout = sys.stdout.buffer
else:
	# Python 2
	stdout = sys.stdout

python_wrapper_scripts_file = open('${T}/python_wrapper_scripts', 'rb')
files = set(python_wrapper_scripts_file.read().rstrip(${b}'\x00').split(${b}'\x00'))
python_wrapper_scripts_file.close()

for file in sorted(files):
	stdout.write(file)
	stdout.write(${b}'\x00')" || die "${FUNCNAME}(): Failure of extraction of set of wrapper scripts")

		python_generate_wrapper_scripts $([[ "${quiet}" == "1" ]] && echo --quiet) "${wrapper_scripts_set[@]}"
	fi
}

# @FUNCTION: python_install_executables
# @USAGE: [-q|--quiet] [--] <file> [files]
# @DESCRIPTION:
# Install versioned executables (including Python scripts).
#
# This function can be used only in src_install() phase.
python_install_executables() {
	if [[ "${EBUILD_PHASE}" != "install" ]]; then
		die "${FUNCNAME}() can be used only in src_install() phase"
	fi

	if ! _python_abi_type multiple; then
		die "${FUNCNAME}() can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"multiple\" variable"
	fi

	_python_check_python_pkg_setup_execution
	_python_initialize_prefix_variables

	local file files=() intermediate_installation_images_directory PYTHON_VERSIONED_EXECUTABLES=() quiet="0"

	while (($#)); do
		case "$1" in
			-q|--quiet)
				quiet="1"
				;;
			--)
				shift
				break
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				break
				;;
		esac
		shift
	done

	for file in "$@"; do
		if [[ -f "${file}" ]]; then
			files+=("${file}")
		elif [[ -e "${file}" ]]; then
			die "${FUNCNAME}(): '${file}' is not a regular file"
		else
			die "${FUNCNAME}(): '${file}' does not exist"
		fi
	done

	intermediate_installation_images_directory="$(mktemp -d "${T}/images.XXXXXXXXXXXX")" || die "${FUNCNAME}(): Creation of intermediate installation images directory failed"

	python_install_files() {
		mkdir -p "${intermediate_installation_images_directory}/${PYTHON_ABI}${EPREFIX}/usr/bin"
		install -m 0755 "${files[@]}" "${intermediate_installation_images_directory}/${PYTHON_ABI}${EPREFIX}/usr/bin"
	}
	python_execute_function -q python_install_files

	PYTHON_VERSIONED_EXECUTABLES=(".*")
	python_merge_intermediate_installation_images $([[ "${quiet}" == "1" ]] && echo --quiet) "${intermediate_installation_images_directory}"
}

# ========================================================================================================================
# ========== FUNCTIONS FOR EBUILDS NOT SETTING PYTHON_ABI_TYPE="single" OR PYTHON_ABI_TYPE="multiple" VARIABLE ===========
# ========================================================================================================================

unset EPYTHON PYTHON_ABI

# @FUNCTION: python_set_active_version
# @USAGE: <Python_ABI|2|3>
# @DESCRIPTION:
# Set locally active version of Python.
# If Python_ABI argument is specified, then version of Python corresponding to Python_ABI is used.
# If 2 argument is specified, then active version of CPython 2 is used.
# If 3 argument is specified, then active version of CPython 3 is used.
#
# This function can be used only in pkg_setup() phase.
python_set_active_version() {
	if [[ "${EBUILD_PHASE}" != "setup" ]]; then
		die "${FUNCNAME}() can be used only in pkg_setup() phase"
	fi

	if ! _python_abi_type implicit_single; then
		die "${FUNCNAME}() can not be used in ebuilds setting PYTHON_ABI_TYPE=\"single\" or PYTHON_ABI_TYPE=\"multiple\" variable"
	fi

	if [[ "$#" -ne 1 ]]; then
		die "${FUNCNAME}() requires 1 argument"
	fi

	_python_initial_sanity_checks

	if [[ -z "${PYTHON_ABI}" ]]; then
		if [[ -n "$(_python_get_implementation --ignore-invalid "$1")" ]]; then
			# PYTHON_ABI variable is intended to be used only in ebuilds/eclasses,
			# so it does not need to be exported to subprocesses.
			PYTHON_ABI="$1"
			if ! _python_implementation; then
				if ! ROOT="/" has_version "$(python_get_implementational_package)"; then
					die "${FUNCNAME}(): '$(python_get_implementational_package)' not installed in ROOT=\"/\""
				fi
				if [[ "${ROOT}" != "/" ]] && _python_check_run-time_dependency; then
					if ! has_version "$(python_get_implementational_package)"; then
						die "${FUNCNAME}(): '$(python_get_implementational_package)' not installed in ROOT=\"${ROOT}\""
					fi
				fi
			fi
			export EPYTHON="$(PYTHON "$1")"
		elif [[ "$1" == "2" ]]; then
			if ! _python_implementation; then
				if ! ROOT="/" has_version "=dev-lang/python-2*"; then
					die "${FUNCNAME}(): '=dev-lang/python-2*' not installed in ROOT=\"/\""
				fi
				if [[ "${ROOT}" != "/" ]] && _python_check_run-time_dependency; then
					if ! has_version "=dev-lang/python-2*"; then
						die "${FUNCNAME}(): '=dev-lang/python-2*' not installed in ROOT=\"${ROOT}\""
					fi
				fi
			fi
			export EPYTHON="$(PYTHON -2)"
			PYTHON_ABI="${EPYTHON#python}"
			PYTHON_ABI="${PYTHON_ABI%%-*}"
		elif [[ "$1" == "3" ]]; then
			if ! _python_implementation; then
				if ! ROOT="/" has_version "=dev-lang/python-3*"; then
					die "${FUNCNAME}(): '=dev-lang/python-3*' not installed ROOT=\"/\""
				fi
				if [[ "${ROOT}" != "/" ]] && _python_check_run-time_dependency; then
					if ! has_version "=dev-lang/python-3*"; then
						die "${FUNCNAME}(): '=dev-lang/python-3*' not installed ROOT=\"${ROOT}\""
					fi
				fi
			fi
			export EPYTHON="$(PYTHON -3)"
			PYTHON_ABI="${EPYTHON#python}"
			PYTHON_ABI="${PYTHON_ABI%%-*}"
		else
			die "${FUNCNAME}(): Unrecognized argument '$1'"
		fi
	fi

	_python_final_sanity_checks

	# python-updater checks PYTHON_REQUESTED_ACTIVE_VERSION variable.
	PYTHON_REQUESTED_ACTIVE_VERSION="$1"
}

# @FUNCTION: python_need_rebuild
# @DESCRIPTION:
# Mark current package for rebuilding by python-updater after switching of active version of Python.
python_need_rebuild() {
	if ! _python_abi_type implicit_single; then
		die "${FUNCNAME}() can not be used in ebuilds setting PYTHON_ABI_TYPE=\"single\" or PYTHON_ABI_TYPE=\"multiple\" variable"
	fi

	_python_check_python_pkg_setup_execution

	if [[ "$#" -ne 0 ]]; then
		die "${FUNCNAME}() does not accept arguments"
	fi

	export PYTHON_NEED_REBUILD="$(PYTHON --ABI)"
}

# ========================================================================================================================
# =================================================== GETTER FUNCTIONS ===================================================
# ========================================================================================================================

_PYTHON_ABI_EXTRACTION_COMMAND=\
'import platform
import sys
sys.stdout.write(".".join(str(x) for x in sys.version_info[:2]))
if platform.system()[:4] == "Java":
	sys.stdout.write("-jython")
elif hasattr(platform, "python_implementation") and platform.python_implementation() == "PyPy":
	sys.stdout.write("-pypy")'

_python_get_implementation() {
	local ignore_invalid="0"

	while (($#)); do
		case "$1" in
			--ignore-invalid)
				ignore_invalid="1"
				;;
			--)
				shift
				break
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				break
				;;
		esac
		shift
	done

	if [[ "$#" -ne 1 ]]; then
		die "${FUNCNAME}() requires 1 argument"
	fi

	if [[ "$1" =~ ^[[:digit:]]+\.[[:digit:]]+$ ]]; then
		echo "CPython"
	elif [[ "$1" =~ ^[[:digit:]]+\.[[:digit:]]+-jython$ ]]; then
		echo "Jython"
	elif [[ "$1" =~ ^[[:digit:]]+\.[[:digit:]]+-pypy$ ]]; then
		echo "PyPy"
	else
		if [[ "${ignore_invalid}" == "0" ]]; then
			die "${FUNCNAME}(): Unrecognized Python ABI '$1'"
		fi
	fi
}

_python_get_platform_triplet() {
	local platform_triplet processed_code source_code

	# Code copied from configure.ac of CPython.
	source_code="
#undef bfin
#undef cris
#undef fr30
#undef linux
#undef hppa
#undef hpux
#undef i386
#undef mips
#undef powerpc
#undef sparc
#undef unix
#if defined(__ANDROID__)
    # Android is not a multiarch system.
#elif defined(__linux__)
# if defined(__x86_64__) && defined(__LP64__)
        x86_64-linux-gnu
# elif defined(__x86_64__) && defined(__ILP32__)
        x86_64-linux-gnux32
# elif defined(__i386__)
        i386-linux-gnu
# elif defined(__aarch64__) && defined(__AARCH64EL__)
#  if defined(__ILP32__)
        aarch64_ilp32-linux-gnu
#  else
        aarch64-linux-gnu
#  endif
# elif defined(__aarch64__) && defined(__AARCH64EB__)
#  if defined(__ILP32__)
        aarch64_be_ilp32-linux-gnu
#  else
        aarch64_be-linux-gnu
#  endif
# elif defined(__alpha__)
        alpha-linux-gnu
# elif defined(__ARM_EABI__) && defined(__ARM_PCS_VFP)
#  if defined(__ARMEL__)
        arm-linux-gnueabihf
#  else
        armeb-linux-gnueabihf
#  endif
# elif defined(__ARM_EABI__) && !defined(__ARM_PCS_VFP)
#  if defined(__ARMEL__)
        arm-linux-gnueabi
#  else
        armeb-linux-gnueabi
#  endif
# elif defined(__hppa__)
        hppa-linux-gnu
# elif defined(__ia64__)
        ia64-linux-gnu
# elif defined(__m68k__) && !defined(__mcoldfire__)
        m68k-linux-gnu
# elif defined(__mips_hard_float) && defined(_MIPSEL)
#  if _MIPS_SIM == _ABIO32
        mipsel-linux-gnu
#  elif _MIPS_SIM == _ABIN32
        mips64el-linux-gnuabin32
#  elif _MIPS_SIM == _ABI64
        mips64el-linux-gnuabi64
#  else
#   error unknown platform triplet
#  endif
# elif defined(__mips_hard_float)
#  if _MIPS_SIM == _ABIO32
        mips-linux-gnu
#  elif _MIPS_SIM == _ABIN32
        mips64-linux-gnuabin32
#  elif _MIPS_SIM == _ABI64
        mips64-linux-gnuabi64
#  else
#   error unknown platform triplet
#  endif
# elif defined(__or1k__)
        or1k-linux-gnu
# elif defined(__powerpc__) && defined(__SPE__)
        powerpc-linux-gnuspe
# elif defined(__powerpc64__)
#  if defined(__LITTLE_ENDIAN__)
        powerpc64le-linux-gnu
#  else
        powerpc64-linux-gnu
#  endif
# elif defined(__powerpc__)
        powerpc-linux-gnu
# elif defined(__s390x__)
        s390x-linux-gnu
# elif defined(__s390__)
        s390-linux-gnu
# elif defined(__sh__) && defined(__LITTLE_ENDIAN__)
        sh4-linux-gnu
# elif defined(__sparc__) && defined(__arch64__)
        sparc64-linux-gnu
# elif defined(__sparc__)
        sparc-linux-gnu
# else
#   error unknown platform triplet
# endif
#elif defined(__FreeBSD_kernel__)
# if defined(__LP64__)
        x86_64-kfreebsd-gnu
# elif defined(__i386__)
        i386-kfreebsd-gnu
# else
#   error unknown platform triplet
# endif
#elif defined(__gnu_hurd__)
        i386-gnu
#elif defined(__APPLE__)
        darwin
#else
# error unknown platform triplet
#endif
"

	processed_code="$(${_PYTHON_TOOLCHAIN_FUNCS_CPP} -x c - <<< "${source_code}" 2> /dev/null)"
	if [[ "$?" == "0" ]]; then
		platform_triplet="$(grep -v "^#" <<< "${processed_code}" | grep -v "^ *$" | tr -d "        ")"
	else
		platform_triplet=""
	fi

	if [[ -n "${platform_triplet}" ]]; then
		echo "${platform_triplet}"
	fi
}

# @FUNCTION: PYTHON
# @USAGE: [-2] [-3] [--ABI] [-a|--absolute-path] [-f|--final-ABI] [--] <Python_ABI="${PYTHON_ABI}">
# @DESCRIPTION:
# Print filename of Python interpreter for specified Python ABI. If Python_ABI argument
# is ommitted, then PYTHON_ABI environment variable must be set and is used.
# If -2 option is specified, then active version of CPython 2 is used.
# If -3 option is specified, then active version of CPython 3 is used.
# If --final-ABI option is specified, then final ABI from the list of enabled ABIs is used.
# -2, -3 and --final-ABI options and Python_ABI argument can not be specified simultaneously.
# If --ABI option is specified, then only specified Python ABI is printed instead of
# filename of Python interpreter.
# If --absolute-path option is specified, then absolute path to Python interpreter is printed.
# --ABI and --absolute-path options can not be specified simultaneously.
PYTHON() {
	_python_check_python_pkg_setup_execution

	local ABI_output="0" absolute_path_output="0" final_ABI="0" PYTHON_ABI="${PYTHON_ABI}" python_interpreter python2="0" python3="0"

	while (($#)); do
		case "$1" in
			-2)
				python2="1"
				;;
			-3)
				python3="1"
				;;
			--ABI)
				ABI_output="1"
				;;
			-a|--absolute-path)
				absolute_path_output="1"
				;;
			-f|--final-ABI)
				final_ABI="1"
				;;
			--)
				shift
				break
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				break
				;;
		esac
		shift
	done

	if [[ "${ABI_output}" == "1" && "${absolute_path_output}" == "1" ]]; then
		die "${FUNCNAME}(): '--ABI' and '--absolute-path' options can not be specified simultaneously"
	fi

	if [[ "$((${python2} + ${python3} + ${final_ABI}))" -gt 1 ]]; then
		die "${FUNCNAME}(): '-2', '-3' or '--final-ABI' options can not be specified simultaneously"
	fi

	if [[ "$#" -eq 0 ]]; then
		if [[ "${final_ABI}" == "1" ]]; then
			if ! _python_abi_type multiple; then
				die "${FUNCNAME}(): '--final-ABI' option can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"multiple\" variable"
			fi
			if has "${EAPI:-0}" 0 1 2 3 4 5; then
				_python_calculate_PYTHON_ABIS
			fi
			PYTHON_ABI="${PYTHON_ABIS##* }"
		elif [[ "${python2}" == "1" ]]; then
			PYTHON_ABI="$(ROOT="/" eselect python show --python2 --ABI)"
			if [[ -z "${PYTHON_ABI}" ]]; then
				die "${FUNCNAME}(): Active version of CPython 2 not set"
			elif [[ "${PYTHON_ABI}" != "2."* ]]; then
				die "${FUNCNAME}(): Internal error in \`eselect python show --python2\`"
			fi
		elif [[ "${python3}" == "1" ]]; then
			PYTHON_ABI="$(ROOT="/" eselect python show --python3 --ABI)"
			if [[ -z "${PYTHON_ABI}" ]]; then
				die "${FUNCNAME}(): Active version of CPython 3 not set"
			elif [[ "${PYTHON_ABI}" != "3."* ]]; then
				die "${FUNCNAME}(): Internal error in \`eselect python show --python3\`"
			fi
		elif _python_abi_type single; then
			:
		elif _python_abi_type multiple; then
			if ! _python_abi-specific_local_scope; then
				die "${FUNCNAME}() should be used in ABI-specific local scope"
			fi
		else
			PYTHON_ABI="$("${EPREFIX}/usr/bin/python" -c "${_PYTHON_ABI_EXTRACTION_COMMAND}")"
			if [[ -z "${PYTHON_ABI}" ]]; then
				die "${FUNCNAME}(): Failure of extraction of locally active version of Python"
			fi
		fi
	elif [[ "$#" -eq 1 ]]; then
		if [[ "${final_ABI}" == "1" ]]; then
			die "${FUNCNAME}(): '--final-ABI' option and Python ABI can not be specified simultaneously"
		fi
		if [[ "${python2}" == "1" ]]; then
			die "${FUNCNAME}(): '-2' option and Python ABI can not be specified simultaneously"
		fi
		if [[ "${python3}" == "1" ]]; then
			die "${FUNCNAME}(): '-3' option and Python ABI can not be specified simultaneously"
		fi
		PYTHON_ABI="$1"
	else
		die "${FUNCNAME}(): Invalid usage"
	fi

	if [[ "${ABI_output}" == "1" ]]; then
		echo -n "${PYTHON_ABI}"
		return
	else
		if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "CPython" ]]; then
			python_interpreter="python${PYTHON_ABI}"
		elif [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "Jython" ]]; then
			python_interpreter="jython${PYTHON_ABI%-jython}"
		elif [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "PyPy" ]]; then
			python_interpreter="pypy-python${PYTHON_ABI%-pypy}"
		fi

		if [[ "${absolute_path_output}" == "1" ]]; then
			echo -n "${EPREFIX}/usr/bin/${python_interpreter}"
		else
			echo -n "${python_interpreter}"
		fi
	fi

	if [[ -n "${ABI}" && "${ABI}" != "${DEFAULT_ABI}" && "${DEFAULT_ABI}" != "default" ]]; then
		echo -n "-${ABI}"
	fi
}

# @FUNCTION: python_get_implementation
# @USAGE: [-f|--final-ABI]
# @DESCRIPTION:
# Print name of Python implementation.
# If --final-ABI option is specified, then final ABI from the list of enabled ABIs is used.
python_get_implementation() {
	_python_check_python_pkg_setup_execution

	local final_ABI="0" PYTHON_ABI="${PYTHON_ABI}"

	while (($#)); do
		case "$1" in
			-f|--final-ABI)
				final_ABI="1"
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				die "${FUNCNAME}(): Invalid usage"
				;;
		esac
		shift
	done

	if [[ "${final_ABI}" == "1" ]]; then
		if ! _python_abi_type multiple; then
			die "${FUNCNAME}(): '--final-ABI' option can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"multiple\" variable"
		fi
		PYTHON_ABI="$(PYTHON -f --ABI)"
	else
		if _python_abi_type multiple; then
			if ! _python_abi-specific_local_scope; then
				die "${FUNCNAME}() should be used in ABI-specific local scope"
			fi
		else
			PYTHON_ABI="${PYTHON_ABI:-$(PYTHON --ABI)}"
		fi
	fi

	echo "$(_python_get_implementation "${PYTHON_ABI}")"
}

# @FUNCTION: python_get_implementational_package
# @USAGE: [-f|--final-ABI]
# @DESCRIPTION:
# Print category, name and slot of package providing Python implementation.
# If --final-ABI option is specified, then final ABI from the list of enabled ABIs is used.
python_get_implementational_package() {
	_python_check_python_pkg_setup_execution

	local final_ABI="0" PYTHON_ABI="${PYTHON_ABI}"

	while (($#)); do
		case "$1" in
			-f|--final-ABI)
				final_ABI="1"
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				die "${FUNCNAME}(): Invalid usage"
				;;
		esac
		shift
	done

	if [[ "${final_ABI}" == "1" ]]; then
		if ! _python_abi_type multiple; then
			die "${FUNCNAME}(): '--final-ABI' option can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"multiple\" variable"
		fi
		PYTHON_ABI="$(PYTHON -f --ABI)"
	else
		if _python_abi_type multiple; then
			if ! _python_abi-specific_local_scope; then
				die "${FUNCNAME}() should be used in ABI-specific local scope"
			fi
		else
			PYTHON_ABI="${PYTHON_ABI:-$(PYTHON --ABI)}"
		fi
	fi

	if [[ "${EAPI:-0}" == "0" ]]; then
		if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "CPython" ]]; then
			echo "=dev-lang/python-${PYTHON_ABI}*"
		elif [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "Jython" ]]; then
			echo "=dev-lang/jython-${PYTHON_ABI%-jython}*"
		elif [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "PyPy" ]]; then
			echo "=dev-lang/pypy-${PYTHON_ABI%-pypy}*"
		fi
	else
		if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "CPython" ]]; then
			echo "dev-lang/python:${PYTHON_ABI}"
		elif [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "Jython" ]]; then
			echo "dev-lang/jython:${PYTHON_ABI%-jython}"
		elif [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "PyPy" ]]; then
			echo "dev-lang/pypy:${PYTHON_ABI%-pypy}"
		fi
	fi
}

# @FUNCTION: python_get_includedir
# @USAGE: [-b|--base-path] [-f|--final-ABI]
# @DESCRIPTION:
# Print path to Python include directory.
# If --base-path option is specified, then path not prefixed with "/" is printed.
# If --final-ABI option is specified, then final ABI from the list of enabled ABIs is used.
python_get_includedir() {
	_python_check_python_pkg_setup_execution

	local base_path="0" final_ABI="0" prefix PYTHON_ABI="${PYTHON_ABI}"

	while (($#)); do
		case "$1" in
			-b|--base-path)
				base_path="1"
				;;
			-f|--final-ABI)
				final_ABI="1"
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				die "${FUNCNAME}(): Invalid usage"
				;;
		esac
		shift
	done

	if [[ "${base_path}" == "0" ]]; then
		prefix="/"
	fi

	if [[ "${final_ABI}" == "1" ]]; then
		if ! _python_abi_type multiple; then
			die "${FUNCNAME}(): '--final-ABI' option can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"multiple\" variable"
		fi
		PYTHON_ABI="$(PYTHON -f --ABI)"
	else
		if _python_abi_type multiple; then
			if ! _python_abi-specific_local_scope; then
				die "${FUNCNAME}() should be used in ABI-specific local scope"
			fi
		else
			PYTHON_ABI="${PYTHON_ABI:-$(PYTHON --ABI)}"
		fi
	fi

	if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "CPython" ]]; then
		echo "${prefix}usr/include/python${PYTHON_ABI}"
	elif [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "Jython" ]]; then
		echo "${prefix}usr/share/jython-${PYTHON_ABI%-jython}/Include"
	elif [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "PyPy" ]]; then
		echo "${prefix}usr/${_PYTHON_MULTILIB_LIBDIR}/pypy-python${PYTHON_ABI%-pypy}/include"
	fi
}

# @FUNCTION: python_get_libdir
# @USAGE: [-b|--base-path] [-f|--final-ABI]
# @DESCRIPTION:
# Print path to Python standard library directory.
# If --base-path option is specified, then path not prefixed with "/" is printed.
# If --final-ABI option is specified, then final ABI from the list of enabled ABIs is used.
python_get_libdir() {
	_python_check_python_pkg_setup_execution

	local base_path="0" final_ABI="0" prefix PYTHON_ABI="${PYTHON_ABI}" version

	while (($#)); do
		case "$1" in
			-b|--base-path)
				base_path="1"
				;;
			-f|--final-ABI)
				final_ABI="1"
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				die "${FUNCNAME}(): Invalid usage"
				;;
		esac
		shift
	done

	if [[ "${base_path}" == "0" ]]; then
		prefix="/"
	fi

	if [[ "${final_ABI}" == "1" ]]; then
		if ! _python_abi_type multiple; then
			die "${FUNCNAME}(): '--final-ABI' option can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"multiple\" variable"
		fi
		PYTHON_ABI="$(PYTHON -f --ABI)"
	else
		if _python_abi_type multiple; then
			if ! _python_abi-specific_local_scope; then
				die "${FUNCNAME}() should be used in ABI-specific local scope"
			fi
		else
			PYTHON_ABI="${PYTHON_ABI:-$(PYTHON --ABI)}"
		fi
	fi

	if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "CPython" ]]; then
		echo "${prefix}usr/${_PYTHON_MULTILIB_LIBDIR}/python${PYTHON_ABI}"
	elif [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "Jython" ]]; then
		echo "${prefix}usr/share/jython-${PYTHON_ABI%-jython}/Lib"
	elif [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "PyPy" ]]; then
		if [[ "${PYTHON_ABI}" == 2.7-pypy ]]; then
			version="2.7"
		elif [[ "${PYTHON_ABI}" == 3.*-pypy ]]; then
			version="3"
		fi
		echo "${prefix}usr/${_PYTHON_MULTILIB_LIBDIR}/pypy-python${PYTHON_ABI%-pypy}/lib-python/${version}"
	fi
}

# @FUNCTION: python_get_sitedir
# @USAGE: [-b|--base-path] [-f|--final-ABI]
# @DESCRIPTION:
# Print path to Python site-packages directory.
# If --base-path option is specified, then path not prefixed with "/" is printed.
# If --final-ABI option is specified, then final ABI from the list of enabled ABIs is used.
python_get_sitedir() {
	_python_check_python_pkg_setup_execution

	local base_path="0" final_ABI="0" prefix PYTHON_ABI="${PYTHON_ABI}"

	while (($#)); do
		case "$1" in
			-b|--base-path)
				base_path="1"
				;;
			-f|--final-ABI)
				final_ABI="1"
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				die "${FUNCNAME}(): Invalid usage"
				;;
		esac
		shift
	done

	if [[ "${base_path}" == "0" ]]; then
		prefix="/"
	fi

	if [[ "${final_ABI}" == "1" ]]; then
		if ! _python_abi_type multiple; then
			die "${FUNCNAME}(): '--final-ABI' option can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"multiple\" variable"
		fi
		PYTHON_ABI="$(PYTHON -f --ABI)"
	else
		if _python_abi_type multiple; then
			if ! _python_abi-specific_local_scope; then
				die "${FUNCNAME}() should be used in ABI-specific local scope"
			fi
		else
			PYTHON_ABI="${PYTHON_ABI:-$(PYTHON --ABI)}"
		fi
	fi

	if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "CPython" ]]; then
		echo "${prefix}usr/${_PYTHON_MULTILIB_LIBDIR}/python${PYTHON_ABI}/site-packages"
	elif [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "Jython" ]]; then
		echo "${prefix}usr/share/jython-${PYTHON_ABI%-jython}/Lib/site-packages"
	elif [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "PyPy" ]]; then
		echo "${prefix}usr/${_PYTHON_MULTILIB_LIBDIR}/pypy-python${PYTHON_ABI%-pypy}/site-packages"
	fi
}

# @FUNCTION: python_get_library
# @USAGE: [-b|--base-path] [-f|--final-ABI] [-l|--linker-option]
# @DESCRIPTION:
# Print path to Python library.
# If --base-path option is specified, then path not prefixed with "/" is printed.
# If --linker-option is specified, then "-l${library}" linker option is printed.
# If --final-ABI option is specified, then final ABI from the list of enabled ABIs is used.
python_get_library() {
	_python_check_python_pkg_setup_execution

	local base_path="0" final_ABI="0" linker_option="0" prefix PYTHON_ABI="${PYTHON_ABI}"

	while (($#)); do
		case "$1" in
			-b|--base-path)
				base_path="1"
				;;
			-f|--final-ABI)
				final_ABI="1"
				;;
			-l|--linker-option)
				linker_option="1"
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				die "${FUNCNAME}(): Invalid usage"
				;;
		esac
		shift
	done

	if [[ "${base_path}" == "0" ]]; then
		prefix="/"
	fi

	if [[ "${base_path}" == "1" && "${linker_option}" == "1" ]]; then
		die "${FUNCNAME}(): '--base-path' and '--linker-option' options can not be specified simultaneously"
	fi

	if [[ "${final_ABI}" == "1" ]]; then
		if ! _python_abi_type multiple; then
			die "${FUNCNAME}(): '--final-ABI' option can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"multiple\" variable"
		fi
		PYTHON_ABI="$(PYTHON -f --ABI)"
	else
		if _python_abi_type multiple; then
			if ! _python_abi-specific_local_scope; then
				die "${FUNCNAME}() should be used in ABI-specific local scope"
			fi
		else
			PYTHON_ABI="${PYTHON_ABI:-$(PYTHON --ABI)}"
		fi
	fi

	if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "CPython" ]]; then
		if [[ "${linker_option}" == "1" ]]; then
			echo "-lpython${PYTHON_ABI}"
		else
			echo "${prefix}usr/${_PYTHON_MULTILIB_LIBDIR}/libpython${PYTHON_ABI}${_PYTHON_MULTILIB_LIBNAME}"
		fi
	elif [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "Jython" ]]; then
		die "${FUNCNAME}(): Jython does not have shared library"
	elif [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "PyPy" ]]; then
		die "${FUNCNAME}(): PyPy does not have shared library"
	fi
}

# @FUNCTION: python_get_extension_module_suffix
# @USAGE: [-f|--final-ABI]
# @DESCRIPTION:
# Print suffix of filenames of extension modules.
# If --final-ABI option is specified, then final ABI from the list of enabled ABIs is used.
python_get_extension_module_suffix() {
	_python_check_python_pkg_setup_execution

	local extension_module_suffix final_ABI="0" platform_triplet PYTHON_ABI="${PYTHON_ABI}"

	while (($#)); do
		case "$1" in
			-f|--final-ABI)
				final_ABI="1"
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				die "${FUNCNAME}(): Invalid usage"
				;;
		esac
		shift
	done

	if [[ "${final_ABI}" == "1" ]]; then
		if ! _python_abi_type multiple; then
			die "${FUNCNAME}(): '--final-ABI' option can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"multiple\" variable"
		fi
		PYTHON_ABI="$(PYTHON -f --ABI)"
	else
		if _python_abi_type multiple; then
			if ! _python_abi-specific_local_scope; then
				die "${FUNCNAME}() should be used in ABI-specific local scope"
			fi
		else
			PYTHON_ABI="${PYTHON_ABI:-$(PYTHON --ABI)}"
		fi
	fi

	if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "CPython" ]]; then
		if [[ "${PYTHON_ABI%.*}" -lt 3 || "${PYTHON_ABI%.*}" -eq 3 && "${PYTHON_ABI#*.}" -lt 2 ]]; then
			# CPython <3.2
			extension_module_suffix=".so"
		elif [[ "${PYTHON_ABI%.*}" -eq 3 && "${PYTHON_ABI#*.}" -ge 2 && "${PYTHON_ABI#*.}" -lt 5 ]]; then
			# CPython >=3.2 and <3.5
			extension_module_suffix=".cpython-${PYTHON_ABI/./}.so"
		else
			# CPython >=3.5
			platform_triplet="$(_python_get_platform_triplet)"
			extension_module_suffix=".cpython-${PYTHON_ABI/./}${platform_triplet:+-}${platform_triplet}.so"
		fi
	elif [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "Jython" ]]; then
		die "${FUNCNAME}(): Jython does not support extension modules"
	elif [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "PyPy" ]]; then
		extension_module_suffix="$(python_get_version $([[ "${final_ABI}" == "1" ]] && echo -f))"
		if [[ "${PYTHON_ABI}" == 2.*-pypy ]]; then
			extension_module_suffix=".pypy-${extension_module_suffix/./}.so"
		else
			extension_module_suffix=".pypy${PYTHON_ABI%.*-pypy}-${extension_module_suffix/./}.so"
		fi
	fi

	echo "${extension_module_suffix}"
}

# @FUNCTION: python_get_version
# @USAGE: [-f|--final-ABI] [-l|--language] [--full] [--major] [--minor] [--micro]
# @DESCRIPTION:
# Print version of Python implementation.
# --full, --major, --minor and --micro options can not be specified simultaneously.
# If --full, --major, --minor and --micro options are not specified, then "${major_version}.${minor_version}" is printed.
# If --language option is specified, then version of Python language is printed.
# --language and --full options can not be specified simultaneously.
# --language and --micro options can not be specified simultaneously.
# If --final-ABI option is specified, then final ABI from the list of enabled ABIs is used.
python_get_version() {
	_python_check_python_pkg_setup_execution

	local final_ABI="0" language="0" language_version full="0" major="0" minor="0" micro="0" PYTHON_ABI="${PYTHON_ABI}" python_command

	while (($#)); do
		case "$1" in
			-f|--final-ABI)
				final_ABI="1"
				;;
			-l|--language)
				language="1"
				;;
			--full)
				full="1"
				;;
			--major)
				major="1"
				;;
			--minor)
				minor="1"
				;;
			--micro)
				micro="1"
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				die "${FUNCNAME}(): Invalid usage"
				;;
		esac
		shift
	done

	if [[ "${final_ABI}" == "1" ]]; then
		if ! _python_abi_type multiple; then
			die "${FUNCNAME}(): '--final-ABI' option can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"multiple\" variable"
		fi
	else
		if _python_abi_type multiple && ! _python_abi-specific_local_scope; then
			die "${FUNCNAME}() should be used in ABI-specific local scope"
		fi
	fi

	if [[ "$((${full} + ${major} + ${minor} + ${micro}))" -gt 1 ]]; then
		die "${FUNCNAME}(): '--full', '--major', '--minor' or '--micro' options can not be specified simultaneously"
	fi

	if [[ "${language}" == "1" ]]; then
		if [[ "${final_ABI}" == "1" ]]; then
			PYTHON_ABI="$(PYTHON -f --ABI)"
		elif [[ -z "${PYTHON_ABI}" ]]; then
			PYTHON_ABI="$(PYTHON --ABI)"
		fi
		language_version="${PYTHON_ABI%%-*}"
		if [[ "${full}" == "1" ]]; then
			die "${FUNCNAME}(): '--language' and '--full' options can not be specified simultaneously"
		elif [[ "${major}" == "1" ]]; then
			echo "${language_version%.*}"
		elif [[ "${minor}" == "1" ]]; then
			echo "${language_version#*.}"
		elif [[ "${micro}" == "1" ]]; then
			die "${FUNCNAME}(): '--language' and '--micro' options can not be specified simultaneously"
		else
			echo "${language_version}"
		fi
	else
		if [[ "${full}" == "1" ]]; then
			python_command="import sys; print('.'.join(str(x) for x in getattr(sys, 'pypy_version_info', sys.version_info)[:3]))"
		elif [[ "${major}" == "1" ]]; then
			python_command="import sys; print(getattr(sys, 'pypy_version_info', sys.version_info)[0])"
		elif [[ "${minor}" == "1" ]]; then
			python_command="import sys; print(getattr(sys, 'pypy_version_info', sys.version_info)[1])"
		elif [[ "${micro}" == "1" ]]; then
			python_command="import sys; print(getattr(sys, 'pypy_version_info', sys.version_info)[2])"
		else
			if [[ -n "${PYTHON_ABI}" && "${final_ABI}" == "0" ]]; then
				if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "CPython" ]]; then
					echo "${PYTHON_ABI}"
					return
				elif [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "Jython" ]]; then
					echo "${PYTHON_ABI%-jython}"
					return
				elif [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "PyPy" ]]; then
					:
				fi
			fi
			python_command="import sys; print('.'.join(str(x) for x in getattr(sys, 'pypy_version_info', sys.version_info)[:2]))"
		fi

		if [[ "${final_ABI}" == "1" ]]; then
			"$(PYTHON -f)" -c "${python_command}"
		else
			"$(PYTHON ${PYTHON_ABI})" -c "${python_command}"
		fi
	fi
}

# @FUNCTION: python_get_implementation_and_version
# @USAGE: [-f|--final-ABI]
# @DESCRIPTION:
# Print name and version of Python implementation.
# If version of Python implementation is not bound to version of Python language, then
# version of Python language is additionally printed.
# If --final-ABI option is specified, then final ABI from the list of enabled ABIs is used.
python_get_implementation_and_version() {
	_python_check_python_pkg_setup_execution

	local final_ABI="0" PYTHON_ABI="${PYTHON_ABI}"

	while (($#)); do
		case "$1" in
			-f|--final-ABI)
				final_ABI="1"
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				die "${FUNCNAME}(): Invalid usage"
				;;
		esac
		shift
	done

	if [[ "${final_ABI}" == "1" ]]; then
		if ! _python_abi_type multiple; then
			die "${FUNCNAME}(): '--final-ABI' option can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"multiple\" variable"
		fi
		PYTHON_ABI="$(PYTHON -f --ABI)"
	else
		if _python_abi_type multiple; then
			if ! _python_abi-specific_local_scope; then
				die "${FUNCNAME}() should be used in ABI-specific local scope"
			fi
		else
			PYTHON_ABI="${PYTHON_ABI:-$(PYTHON --ABI)}"
		fi
	fi

	if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "PyPy" ]]; then
		echo "PyPy $(python_get_version) (Python ${PYTHON_ABI%%-*})"
	else
		echo "$(_python_get_implementation "${PYTHON_ABI}") ${PYTHON_ABI%%-*}"
	fi
}

# ========================================================================================================================
# ============================================ FUNCTIONS FOR RUNNING OF TESTS ============================================
# ========================================================================================================================

# @ECLASS-VARIABLE: PYTHON_TEST_VERBOSITY
# @DESCRIPTION:
# User-configurable verbosity of tests of Python modules.
# Supported values: 0, 1, 2, 3, 4.
PYTHON_TEST_VERBOSITY="${PYTHON_TEST_VERBOSITY:-1}"

_python_test_hook() {
	if [[ "$#" -ne 1 ]]; then
		die "${FUNCNAME}() requires 1 argument"
	fi

	if { _python_abi_type single || _python_abi_type multiple; } && [[ "$(type -t "${_PYTHON_TEST_FUNCTION}_$1_hook")" == "function" ]]; then
		"${_PYTHON_TEST_FUNCTION}_$1_hook"
	fi
}

# @FUNCTION: python_execute_nosetests
# @USAGE: [-e|--evaluate-arguments] [-P|--PYTHONPATH PYTHONPATH] [-s|--separate-build-dirs] [--] [arguments]
# @DESCRIPTION:
# Execute nosetests for all enabled Python ABIs.
# In ebuilds setting PYTHON_ABI_TYPE="multiple" variable, this function calls python_execute_nosetests_pre_hook()
# and python_execute_nosetests_post_hook(), if they are defined.
python_execute_nosetests() {
	_python_check_python_pkg_setup_execution
	_python_set_color_variables

	local evaluate_arguments="0" PYTHONPATH_template separate_build_dirs="0"

	while (($#)); do
		case "$1" in
			-e|--evaluate-arguments)
				evaluate_arguments="1"
				;;
			-P|--PYTHONPATH)
				PYTHONPATH_template="$2"
				shift
				;;
			-s|--separate-build-dirs)
				separate_build_dirs="1"
				;;
			--)
				shift
				break
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				break
				;;
		esac
		shift
	done

	if ! _python_abi_type multiple && [[ "${separate_build_dirs}" == "1" ]]; then
		die "${FUNCNAME}(): '--separate-build-dirs' option can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"multiple\" variable"
	fi

	python_test_function() {
		local argument arguments=() evaluated_PYTHONPATH

		if [[ "${evaluate_arguments}" == "1" ]]; then
			for argument in "$@"; do
				eval "arguments+=(\"${argument}\")"
			done
		else
			arguments=("$@")
		fi

		eval "evaluated_PYTHONPATH=\"${PYTHONPATH_template}\""

		_PYTHON_TEST_FUNCTION="python_execute_nosetests" _python_test_hook pre

		if [[ -n "${evaluated_PYTHONPATH}" ]]; then
			_python_execute_with_build_environment python_execute PYTHONPATH="${evaluated_PYTHONPATH}" nosetests --verbosity="${PYTHON_TEST_VERBOSITY}" "${arguments[@]}" || return "$?"
		else
			_python_execute_with_build_environment python_execute nosetests --verbosity="${PYTHON_TEST_VERBOSITY}" "${arguments[@]}" || return "$?"
		fi

		_PYTHON_TEST_FUNCTION="python_execute_nosetests" _python_test_hook post
	}
	if _python_abi_type single || _python_abi_type multiple; then
		python_execute_function $([[ "${separate_build_dirs}" == "1" ]] && echo -s) python_test_function "$@"
	else
		python_test_function "$@" || die "Testing failed"
	fi

	unset -f python_test_function
}

# @FUNCTION: python_execute_py.test
# @USAGE: [-e|--evaluate-arguments] [-P|--PYTHONPATH PYTHONPATH] [-s|--separate-build-dirs] [--] [arguments]
# @DESCRIPTION:
# Execute py.test for all enabled Python ABIs.
# In ebuilds setting PYTHON_ABI_TYPE="multiple" variable, this function calls python_execute_py.test_pre_hook()
# and python_execute_py.test_post_hook(), if they are defined.
python_execute_py.test() {
	_python_check_python_pkg_setup_execution
	_python_set_color_variables

	local evaluate_arguments="0" PYTHONPATH_template separate_build_dirs="0"

	while (($#)); do
		case "$1" in
			-e|--evaluate-arguments)
				evaluate_arguments="1"
				;;
			-P|--PYTHONPATH)
				PYTHONPATH_template="$2"
				shift
				;;
			-s|--separate-build-dirs)
				separate_build_dirs="1"
				;;
			--)
				shift
				break
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				break
				;;
		esac
		shift
	done

	if ! _python_abi_type multiple && [[ "${separate_build_dirs}" == "1" ]]; then
		die "${FUNCNAME}(): '--separate-build-dirs' option can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"multiple\" variable"
	fi

	python_test_function() {
		local argument arguments=() evaluated_PYTHONPATH

		if [[ "${evaluate_arguments}" == "1" ]]; then
			for argument in "$@"; do
				eval "arguments+=(\"${argument}\")"
			done
		else
			arguments=("$@")
		fi

		eval "evaluated_PYTHONPATH=\"${PYTHONPATH_template}\""

		_PYTHON_TEST_FUNCTION="python_execute_py.test" _python_test_hook pre

		if [[ -n "${evaluated_PYTHONPATH}" ]]; then
			_python_execute_with_build_environment python_execute PYTHONPATH="${evaluated_PYTHONPATH}" py.test $([[ "${PYTHON_TEST_VERBOSITY}" -ge 2 ]] && echo -v) "${arguments[@]}" || return "$?"
		else
			_python_execute_with_build_environment python_execute py.test $([[ "${PYTHON_TEST_VERBOSITY}" -gt 1 ]] && echo -v) "${arguments[@]}" || return "$?"
		fi

		_PYTHON_TEST_FUNCTION="python_execute_py.test" _python_test_hook post
	}
	if _python_abi_type single || _python_abi_type multiple; then
		python_execute_function $(_python_abi_type multiple && [[ "${separate_build_dirs}" == "1" ]] && echo -s) python_test_function "$@"
	else
		python_test_function "$@" || die "Testing failed"
	fi

	unset -f python_test_function
}

# @FUNCTION: python_execute_trial
# @USAGE: [-e|--evaluate-arguments] [-P|--PYTHONPATH PYTHONPATH] [-s|--separate-build-dirs] [--] [arguments]
# @DESCRIPTION:
# Execute trial for all enabled Python ABIs.
# In ebuilds setting PYTHON_ABI_TYPE="multiple" variable, this function calls calls python_execute_trial_pre_hook()
# and python_execute_trial_post_hook(), if they are defined.
python_execute_trial() {
	_python_check_python_pkg_setup_execution
	_python_set_color_variables

	local evaluate_arguments="0" PYTHONPATH_template separate_build_dirs="0"

	while (($#)); do
		case "$1" in
			-e|--evaluate-arguments)
				evaluate_arguments="1"
				;;
			-P|--PYTHONPATH)
				PYTHONPATH_template="$2"
				shift
				;;
			-s|--separate-build-dirs)
				separate_build_dirs="1"
				;;
			--)
				shift
				break
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				break
				;;
		esac
		shift
	done

	if ! _python_abi_type multiple && [[ "${separate_build_dirs}" == "1" ]]; then
		die "${FUNCNAME}(): '--separate-build-dirs' option can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"multiple\" variable"
	fi

	python_test_function() {
		local argument arguments=() evaluated_PYTHONPATH

		if [[ "${evaluate_arguments}" == "1" ]]; then
			for argument in "$@"; do
				eval "arguments+=(\"${argument}\")"
			done
		else
			arguments=("$@")
		fi

		eval "evaluated_PYTHONPATH=\"${PYTHONPATH_template}\""

		_PYTHON_TEST_FUNCTION="python_execute_trial" _python_test_hook pre

		if [[ -n "${evaluated_PYTHONPATH}" ]]; then
			_python_execute_with_build_environment python_execute PYTHONPATH="${evaluated_PYTHONPATH}" trial $([[ "${PYTHON_TEST_VERBOSITY}" -ge 4 ]] && echo --spew) "${arguments[@]}" || return "$?"
		else
			_python_execute_with_build_environment python_execute trial $([[ "${PYTHON_TEST_VERBOSITY}" -ge 4 ]] && echo --spew) "${arguments[@]}" || return "$?"
		fi

		_PYTHON_TEST_FUNCTION="python_execute_trial" _python_test_hook post
	}
	if _python_abi_type single || _python_abi_type multiple; then
		python_execute_function $(_python_abi_type multiple && [[ "${separate_build_dirs}" == "1" ]] && echo -s) python_test_function "$@"
	else
		python_test_function "$@" || die "Testing failed"
	fi

	unset -f python_test_function
}

# ========================================================================================================================
# =================================== FUNCTIONS FOR HANDLING OF BYTE-COMPILED MODULES ====================================
# ========================================================================================================================

# @FUNCTION: python_enable_byte-compilation
# @DESCRIPTION:
# Enable byte-compilation of *.py Python modules to *.pyc / *.pyo Python modules during:
# - Importation
# - Installation by Distutils
#
# Importational byte-compilation occurs when any of the following properties of *.py Python module
# does not match value cached in header of *.pyc / *.pyo Python module:
# - Magic number
# - Time of last modification of data
# - Size (Python >=3.3)
#
# Byte-compilation should be enabled temporarily and only when it is absolutely necessary.
python_enable_byte-compilation() {
	_python_check_python_pkg_setup_execution

	if [[ "$#" -ne 0 ]]; then
		die "${FUNCNAME}() does not accept arguments"
	fi

	unset PYTHONDONTWRITEBYTECODE
}

# @FUNCTION: python_disable_byte-compilation
# @DESCRIPTION:
# Disable byte-compilation of *.py Python modules to *.pyc / *.pyo Python modules during:
# - Importation
# - Installation by Distutils
#
# Importational byte-compilation occurs when any of the following properties of *.py Python module
# does not match value cached in header of *.pyc / *.pyo Python module:
# - Magic number
# - Time of last modification of data
# - Size (Python >=3.3)
#
# Byte-compilation should be disabled to avoid sandbox violations.
python_disable_byte-compilation() {
	_python_check_python_pkg_setup_execution

	if [[ "$#" -ne 0 ]]; then
		die "${FUNCNAME}() does not accept arguments"
	fi

	export PYTHONDONTWRITEBYTECODE="1"
}

_python_clean_byte-compiled_modules() {
	_python_initialize_prefix_variables
	_python_set_color_variables

	[[ "${FUNCNAME[1]}" =~ ^(python_byte-compile_modules|python_clean_byte-compiled_modules)$ ]] || die "${FUNCNAME}(): Invalid usage"

	local base_module_name compiled_file compiled_files=() dir path previous_extglob_state py_file root

	previous_extglob_state="$(shopt -p extglob)"
	shopt -s extglob

	# Strip trailing slash from EROOT.
	root="${EROOT%/}"

	for path in "$@"; do
		compiled_files=()
		if [[ -d "${path}" ]]; then
			while IFS="" read -d "" -r compiled_file; do
				compiled_files+=("${compiled_file}")
			done < <(find "${path}" "(" -name "*.py[co]" -o -name "*\$py.class" ")" -print0 | sort -z)

			if [[ "${EBUILD_PHASE}" == "postrm" ]]; then
				# Delete empty child directories.
				while IFS="" read -d "" -r dir; do
					if rmdir "${dir}" 2> /dev/null; then
						echo "${_CYAN}<<< ${dir}${_NORMAL}"
					fi
				done < <(find "${path}" -type d -print0 | sort -rz)
			fi
		elif [[ "${path}" == *.py ]]; then
			base_module_name="${path##*/}"
			base_module_name="${base_module_name%.py}"
			if [[ -d "${path%/*}/__pycache__" ]]; then
				while IFS="" read -d "" -r compiled_file; do
					compiled_files+=("${compiled_file}")
				done < <(find "${path%/*}/__pycache__" "(" -name "${base_module_name}.*.py[co]" -o -name "${base_module_name}\$py.class" ")" -print0 | sort -z)
			fi
			compiled_files+=("${path}c" "${path}o" "${path%.py}\$py.class")
		fi

		for compiled_file in "${compiled_files[@]}"; do
			[[ ! -f "${compiled_file}" ]] && continue
			dir="${compiled_file%/*}"
			dir="${dir##*/}"
			if [[ "${compiled_file}" == *.py[co] ]]; then
				if [[ "${dir}" == "__pycache__" ]]; then
					base_module_name="${compiled_file##*/}"
					if [[ "${base_module_name}" =~ \.[[:alpha:]]+-[[:digit:]]+(\.opt-[12])?\.pyc$ ]]; then
						base_module_name="${base_module_name%%.+([[:alpha:]])-+([[:digit:]])?(.opt-+([[:digit:]])).pyc}"
					elif [[ "${base_module_name}" =~ \.[[:alpha:]]+-[[:digit:]]+\.pyo$ ]]; then
						base_module_name="${base_module_name%%.+([[:alpha:]])-+([[:digit:]]).pyo}"
					else
						die "${FUNCNAME}(): Unrecognized file type: '${compiled_file}'"
					fi
					py_file="${compiled_file%__pycache__/*}${base_module_name}.py"
				else
					py_file="${compiled_file%[co]}"
				fi
				if [[ "${EBUILD_PHASE}" == "postinst" ]]; then
					[[ -f "${py_file}" && ! "${compiled_file}" -ot "${py_file}" ]] && continue
				else
					[[ -f "${py_file}" ]] && continue
				fi
				if [[ "${compiled_file}" =~ \.[[:alpha:]]+-[[:digit:]]+(\.opt-[12])?\.pyc$ && -f "${compiled_file%%?(.opt-[12]).pyc}.pyc" && -f "${compiled_file%%?(.opt-[12]).pyc}.opt-1.pyc" && -f "${compiled_file%%?(.opt-[12]).pyc}.opt-2.pyc" ]]; then
					# Standard situation in CPython >=3.5
					echo "${_BLUE}<<< ${compiled_file%%?(.opt-[12]).pyc}.{pyc,opt-[12].pyc}${_NORMAL}"
					rm -f "${compiled_file%%?(.opt-[12]).pyc}".{pyc,opt-[12].pyc}
				elif [[ "${compiled_file}" =~ \.[[:alpha:]]+-[[:digit:]]+\.py[co]$ && -f "${compiled_file%[co]}c" && -f "${compiled_file%[co]}o" ]]; then
					# Standard situation in CPython >=3.2 and <3.5
					echo "${_BLUE}<<< ${compiled_file%[co]}[co]${_NORMAL}"
					rm -f "${compiled_file%[co]}"[co]
				elif [[ -f "${compiled_file%[co]}c" && -f "${compiled_file%[co]}o" ]]; then
					# Standard situation in CPython <3.2
					echo "${_BLUE}<<< ${compiled_file%[co]}[co]${_NORMAL}"
					rm -f "${compiled_file%[co]}"[co]
				else
					echo "${_BLUE}<<< ${compiled_file}${_NORMAL}"
					rm -f "${compiled_file}"
				fi
			elif [[ "${compiled_file}" == *\$py.class ]]; then
				if [[ "${dir}" == "__pycache__" ]]; then
					base_module_name="${compiled_file##*/}"
					base_module_name="${base_module_name%\$py.class}"
					py_file="${compiled_file%__pycache__/*}${base_module_name}.py"
				else
					py_file="${compiled_file%\$py.class}.py"
				fi
				if [[ "${EBUILD_PHASE}" == "postinst" ]]; then
					[[ -f "${py_file}" && ! "${compiled_file}" -ot "${py_file}" ]] && continue
				else
					[[ -f "${py_file}" ]] && continue
				fi
				echo "${_BLUE}<<< ${compiled_file}${_NORMAL}"
				rm -f "${compiled_file}"
			else
				die "${FUNCNAME}(): Unrecognized file type: '${compiled_file}'"
			fi

			# Delete empty parent directories.
			dir="${compiled_file%/*}"
			while [[ "${dir}" != "${root}" ]]; do
				if rmdir "${dir}" 2> /dev/null; then
					echo "${_CYAN}<<< ${dir}${_NORMAL}"
				else
					break
				fi
				dir="${dir%/*}"
			done
		done
	done

	${previous_extglob_state}
}

# @FUNCTION: python_byte-compile_modules
# @USAGE: [-A|--ABIs-patterns Python_ABIs] [--allow-evaluated-non-sitedir-paths] [-d directory] [-f] [-l] [-q] [-x regular_expression] [--] <file|directory> [files|directories]
# @DESCRIPTION:
# Byte-compile specified Python modules.
# -d, -f, -l, -q and -x options passed to this function are passed to compileall.py.
#
# This function can be used only in pkg_postinst() phase.
python_byte-compile_modules() {
	if [[ "${EBUILD_PHASE}" != "postinst" ]]; then
		die "${FUNCNAME}() can be used only in pkg_postinst() phase"
	fi

	_python_check_python_pkg_setup_execution
	_python_initialize_prefix_variables

	if ! has "${EAPI:-0}" 0 1 2 || _python_abi_type single || _python_abi_type multiple || _python_implementation || [[ "${CATEGORY}/${PN}" == "sys-apps/portage" ]]; then
		# PYTHON_ABI variable can not be local in ebuilds not setting PYTHON_ABI_TYPE="single" or PYTHON_ABI_TYPE="multiple" variable.
		local ABIs_patterns="*" allow_evaluated_non_sitedir_paths="0" dir dirs=() enabled_PYTHON_ABI enabled_PYTHON_ABIS evaluated_dirs=() evaluated_files=() exit_status file files=() iterated_PYTHON_ABIS options=() other_dirs=() other_files=() previous_PYTHON_ABI="${PYTHON_ABI}" root site_packages_dirs=() site_packages_files=() stderr stderr_line stderr_lines=()

		if _python_abi_type single; then
			enabled_PYTHON_ABIS="${PYTHON_SINGLE_ABI}"
		elif _python_abi_type multiple; then
			if has "${EAPI:-0}" 0 1 2 3 && [[ -z "${PYTHON_ABIS}" ]]; then
				die "${FUNCNAME}(): python_pkg_setup() or python_execute_function() not called"
			fi
			enabled_PYTHON_ABIS="${PYTHON_ABIS}"
		else
			if has "${EAPI:-0}" 0 1 2 3; then
				enabled_PYTHON_ABIS="${PYTHON_ABI:=$(PYTHON --ABI)}"
			else
				enabled_PYTHON_ABIS="${PYTHON_ABI}"
			fi
		fi

		# Strip trailing slash from EROOT.
		root="${EROOT%/}"

		while (($#)); do
			case "$1" in
				-A|--ABIs-patterns)
					ABIs_patterns="$2"
					shift
					;;
				--allow-evaluated-non-sitedir-paths)
					allow_evaluated_non_sitedir_paths="1"
					;;
				-l|-f|-q)
					options+=("$1")
					;;
				-d|-x)
					options+=("$1" "$2")
					shift
					;;
				--)
					shift
					break
					;;
				-*)
					die "${FUNCNAME}(): Unrecognized option '$1'"
					;;
				*)
					break
					;;
			esac
			shift
		done

		if ! _python_abi_type multiple && [[ "${allow_evaluated_non_sitedir_paths}" == "1" ]]; then
			die "${FUNCNAME}(): '--allow-evaluated-non-sitedir-paths' option can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"multiple\" variable"
		fi

		if [[ "$#" -eq 0 ]]; then
			die "${FUNCNAME}(): Missing files or directories"
		fi

		for enabled_PYTHON_ABI in ${enabled_PYTHON_ABIS}; do
			if _python_check_python_abi_matching --patterns-list "${enabled_PYTHON_ABI}" "${ABIs_patterns}"; then
				iterated_PYTHON_ABIS+="${iterated_PYTHON_ABIS:+ }${enabled_PYTHON_ABI}"
			fi
		done

		while (($#)); do
			if [[ "$1" =~ ^($|(\.|\.\.|/)($|/)) ]]; then
				die "${FUNCNAME}(): Invalid argument '$1'"
			elif ! _python_implementation && [[ "$1" =~ ^/usr/lib(32|64)?/python[[:digit:]]+\.[[:digit:]]+ ]]; then
				die "${FUNCNAME}(): Paths of directories / files in site-packages directories must be relative to site-packages directories"
			elif [[ "$1" =~ ^/ ]]; then
				if _python_abi_type multiple; then
					if [[ "${allow_evaluated_non_sitedir_paths}" != "1" ]]; then
						die "${FUNCNAME}(): Absolute paths can not be used in ebuilds setting PYTHON_ABI_TYPE=\"multiple\" variable"
					fi
					if [[ "$1" != *\$* ]]; then
						die "${FUNCNAME}(): '$1' has invalid syntax"
					fi
					if [[ -n "${iterated_PYTHON_ABIS}" ]]; then
						if [[ "$1" == *.py ]]; then
							evaluated_files+=("$1")
						else
							evaluated_dirs+=("$1")
						fi
					fi
				else
					if [[ -n "${iterated_PYTHON_ABIS}" ]]; then
						if [[ -d "${root}$1" ]]; then
							other_dirs+=("${root}$1")
						elif [[ -f "${root}$1" ]]; then
							other_files+=("${root}$1")
						elif [[ -e "${root}$1" ]]; then
							eerror "${FUNCNAME}(): '${root}$1' is not a regular file or a directory"
						else
							eerror "${FUNCNAME}(): '${root}$1' does not exist"
						fi
					fi
				fi
			else
				for PYTHON_ABI in ${iterated_PYTHON_ABIS}; do
					if [[ -d "${root}$(python_get_sitedir)/$1" ]]; then
						site_packages_dirs+=("$1")
						break
					elif [[ -f "${root}$(python_get_sitedir)/$1" ]]; then
						site_packages_files+=("$1")
						break
					elif [[ -e "${root}$(python_get_sitedir)/$1" ]]; then
						eerror "${FUNCNAME}(): '$1' is not a regular file or a directory"
					else
						eerror "${FUNCNAME}(): '$1' does not exist"
					fi
				done
			fi
			shift
		done

		# Set additional options.
		options+=("-q")

		for PYTHON_ABI in ${iterated_PYTHON_ABIS}; do
			if ((${#site_packages_dirs[@]})) || ((${#site_packages_files[@]})) || ((${#evaluated_dirs[@]})) || ((${#evaluated_files[@]})); then
				exit_status="0"
				stderr=""
				stderr_lines=()
				ebegin "Byte-compilation of Python modules for $(python_get_implementation_and_version)"
				if ((${#site_packages_dirs[@]})) || ((${#evaluated_dirs[@]})); then
					dirs=()
					for dir in "${site_packages_dirs[@]}"; do
						dirs+=("${root}$(python_get_sitedir)/${dir}")
					done
					for dir in "${evaluated_dirs[@]}"; do
						eval "dirs+=(\"\${root}${dir}\")"
					done
					if [[ "$(python_get_version -l --major)" -lt 3 || ("$(python_get_version -l --major)" -eq 3 && "$(python_get_version -l --minor)" -lt 5) ]]; then
						# Python <3.5
						stderr+="${stderr:+$'\n'}$("$(PYTHON)" -m compileall -f "${options[@]}" "${dirs[@]}" 2>&1)" || exit_status="1"
						if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "CPython" ]]; then
							# CPython <3.5
							"$(PYTHON)" -O -m compileall -f "${options[@]}" "${dirs[@]}" &> /dev/null || exit_status="1"
						fi
					else
						# Python >=3.5
						stderr+="${stderr:+$'\n'}$("$(PYTHON)" -m compileall -f "${options[@]}" "${dirs[@]}" 2>&1)" || exit_status="1"
						if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "CPython" ]]; then
							# CPython >=3.5
							"$(PYTHON)" -O -m compileall -f "${options[@]}" "${dirs[@]}" &> /dev/null || exit_status="1"
							"$(PYTHON)" -OO -m compileall -f "${options[@]}" "${dirs[@]}" &> /dev/null || exit_status="1"
						fi
					fi
					_python_clean_byte-compiled_modules "${dirs[@]}"
				fi
				if ((${#site_packages_files[@]})) || ((${#evaluated_files[@]})); then
					files=()
					for file in "${site_packages_files[@]}"; do
						files+=("${root}$(python_get_sitedir)/${file}")
					done
					for file in "${evaluated_files[@]}"; do
						eval "files+=(\"\${root}${file}\")"
					done
					if [[ ("$(python_get_version -l --major)" -eq 2 && "$(python_get_version -l --minor)" -lt 7) || ("$(python_get_version -l --major)" -eq 3 && "$(python_get_version -l --minor)" -lt 2) ]]; then
						# Python 2.6 or 3.1
						stderr+="${stderr:+$'\n'}$("$(PYTHON)" -m py_compile "${files[@]}" 2>&1)" || exit_status="1"
						if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "CPython" ]]; then
							# CPython 2.6 or 3.1
							"$(PYTHON)" -O -m py_compile "${files[@]}" &> /dev/null || exit_status="1"
						fi
					elif [[ ("$(python_get_version -l --major)" -eq 2 && "$(python_get_version -l --minor)" -ge 7) || ("$(python_get_version -l --major)" -eq 3 && "$(python_get_version -l --minor)" -ge 2 && "$(python_get_version -l --minor)" -lt 5) ]]; then
						# Python 2.7 or >=3.2 and <3.5
						stderr+="${stderr:+$'\n'}$("$(PYTHON)" -m compileall -f "${options[@]}" "${files[@]}" 2>&1)" || exit_status="1"
						if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "CPython" ]]; then
							# CPython 2.7 or >=3.2 and <3.5
							"$(PYTHON)" -O -m compileall -f "${options[@]}" "${files[@]}" &> /dev/null || exit_status="1"
						fi
					else
						# Python >=3.5
						stderr+="${stderr:+$'\n'}$("$(PYTHON)" -m compileall -f "${options[@]}" "${files[@]}" 2>&1)" || exit_status="1"
						if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "CPython" ]]; then
							# CPython >=3.5
							"$(PYTHON)" -O -m compileall -f "${options[@]}" "${files[@]}" &> /dev/null || exit_status="1"
							"$(PYTHON)" -OO -m compileall -f "${options[@]}" "${files[@]}" &> /dev/null || exit_status="1"
						fi
					fi
					_python_clean_byte-compiled_modules "${files[@]}"
				fi
				eend "${exit_status}"
				if [[ -n "${stderr}" ]]; then
					while IFS="" read -r stderr_line; do
						# Ignore debugging output of Jython.
						if [[ ! ("$(_python_get_implementation "${PYTHON_ABI}")" == "Jython" && "${stderr_line}" =~ ^"*sys-package-mgr*: processing "(new|modified)" jar") ]]; then
							stderr_lines+=("${stderr_line}")
						fi
					done <<< "${stderr}"
					if [[ "${#stderr_lines[@]}" -ge 1 ]]; then
						eerror "Syntax errors / warnings in Python modules for $(python_get_implementation_and_version):" &> /dev/null
						for stderr_line in "${stderr_lines[@]}"; do
							eerror "    ${stderr_line}"
						done
					fi
				fi
			fi
		done

		if _python_abi_type multiple; then
			# Restore previous value of PYTHON_ABI.
			if [[ -n "${previous_PYTHON_ABI}" ]]; then
				PYTHON_ABI="${previous_PYTHON_ABI}"
			else
				unset PYTHON_ABI
			fi
		fi

		if ((${#other_dirs[@]})) || ((${#other_files[@]})); then
			exit_status="0"
			stderr=""
			stderr_lines=()
			ebegin "Byte-compilation of Python modules placed outside of site-packages directories for $(python_get_implementation_and_version)"
			if ((${#other_dirs[@]})); then
				if [[ "$(python_get_version -l --major)" -lt 3 || ("$(python_get_version -l --major)" -eq 3 && "$(python_get_version -l --minor)" -lt 5) ]]; then
					# Python <3.5
					stderr+="${stderr:+$'\n'}$("$(PYTHON ${PYTHON_ABI})" -m compileall -f "${options[@]}" "${other_dirs[@]}" 2>&1)" || exit_status="1"
					if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "CPython" ]]; then
						# CPython <3.5
						"$(PYTHON ${PYTHON_ABI})" -O -m compileall -f "${options[@]}" "${other_dirs[@]}" &> /dev/null || exit_status="1"
					fi
				else
					# Python >=3.5
					stderr+="${stderr:+$'\n'}$("$(PYTHON ${PYTHON_ABI})" -m compileall -f "${options[@]}" "${other_dirs[@]}" 2>&1)" || exit_status="1"
					if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "CPython" ]]; then
						# CPython >=3.5
						"$(PYTHON ${PYTHON_ABI})" -O -m compileall -f "${options[@]}" "${other_dirs[@]}" &> /dev/null || exit_status="1"
						"$(PYTHON ${PYTHON_ABI})" -OO -m compileall -f "${options[@]}" "${other_dirs[@]}" &> /dev/null || exit_status="1"
					fi
				fi
				_python_clean_byte-compiled_modules "${other_dirs[@]}"
			fi
			if ((${#other_files[@]})); then
				if [[ ("$(python_get_version -l --major)" -eq 2 && "$(python_get_version -l --minor)" -lt 7) || ("$(python_get_version -l --major)" -eq 3 && "$(python_get_version -l --minor)" -lt 2) ]]; then
					# Python 2.6 or 3.1
					stderr+="${stderr:+$'\n'}$("$(PYTHON ${PYTHON_ABI})" -m py_compile "${other_files[@]}" 2>&1)" || exit_status="1"
					if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "CPython" ]]; then
						# CPython 2.6 or 3.1
						"$(PYTHON ${PYTHON_ABI})" -O -m py_compile "${other_files[@]}" &> /dev/null || exit_status="1"
					fi
				elif [[ ("$(python_get_version -l --major)" -eq 2 && "$(python_get_version -l --minor)" -ge 7) || ("$(python_get_version -l --major)" -eq 3 && "$(python_get_version -l --minor)" -ge 2 && "$(python_get_version -l --minor)" -lt 5) ]]; then
					# Python 2.7 or >=3.2 and <3.5
					stderr+="${stderr:+$'\n'}$("$(PYTHON ${PYTHON_ABI})" -m compileall -f "${options[@]}" "${other_files[@]}" 2>&1)" || exit_status="1"
					if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "CPython" ]]; then
						# CPython 2.7 or >=3.2 and <3.5
						"$(PYTHON ${PYTHON_ABI})" -O -m compileall -f "${options[@]}" "${other_files[@]}" &> /dev/null || exit_status="1"
					fi
				else
					# Python >=3.5
					stderr+="${stderr:+$'\n'}$("$(PYTHON ${PYTHON_ABI})" -m compileall -f "${options[@]}" "${other_files[@]}" 2>&1)" || exit_status="1"
					if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "CPython" ]]; then
						# CPython >=3.5
						"$(PYTHON ${PYTHON_ABI})" -O -m compileall -f "${options[@]}" "${other_files[@]}" &> /dev/null || exit_status="1"
						"$(PYTHON ${PYTHON_ABI})" -OO -m compileall -f "${options[@]}" "${other_files[@]}" &> /dev/null || exit_status="1"
					fi
				fi
				_python_clean_byte-compiled_modules "${other_files[@]}"
			fi
			eend "${exit_status}"
			if [[ -n "${stderr}" ]]; then
				while IFS="" read -r stderr_line; do
					# Ignore debugging output of Jython.
					if [[ ! ("$(_python_get_implementation "${PYTHON_ABI}")" == "Jython" && "${stderr_line}" =~ ^"*sys-package-mgr*: processing "(new|modified)" jar") ]]; then
						stderr_lines+=("${stderr_line}")
					fi
				done <<< "${stderr}"
				if [[ "${#stderr_lines[@]}" -ge 1 ]]; then
					eerror "Syntax errors / warnings in Python modules placed outside of site-packages directories for $(python_get_implementation_and_version):" &> /dev/null
					for stderr_line in "${stderr_lines[@]}"; do
						eerror "    ${stderr_line}"
					done
				fi
			fi
		fi
	else
		# Deprecated part of python_byte-compile_modules()
		ewarn
		ewarn "Deprecation Warning: Usage of ${FUNCNAME}() in ebuilds not setting PYTHON_ABI_TYPE=\"single\""
		ewarn "or PYTHON_ABI_TYPE=\"multiple\" variable in EAPI <=2 is deprecated and will be disallowed on 2017-01-01."
		ewarn "Use EAPI >=3 and call ${FUNCNAME}() with paths having appropriate syntax."
		ewarn "The ebuild needs to be fixed. Please report a bug, if it has not been already reported."
		ewarn

		local myroot mydirs=() myfiles=() myopts=() return_code="0"

		# strip trailing slash
		myroot="${EROOT%/}"

		# respect EROOT and options passed to compileall.py
		while (($#)); do
			case "$1" in
				-l|-f|-q)
					myopts+=("$1")
					;;
				-d|-x)
					myopts+=("$1" "$2")
					shift
					;;
				--)
					shift
					break
					;;
				-*)
					die "${FUNCNAME}(): Unrecognized option '$1'"
					;;
				*)
					break
					;;
			esac
			shift
		done

		if [[ "$#" -eq 0 ]]; then
			die "${FUNCNAME}(): Missing files or directories"
		fi

		while (($#)); do
			if [[ "$1" =~ ^($|(\.|\.\.|/)($|/)) ]]; then
				die "${FUNCNAME}(): Invalid argument '$1'"
			elif [[ -d "${myroot}/${1#/}" ]]; then
				mydirs+=("${myroot}/${1#/}")
			elif [[ -f "${myroot}/${1#/}" ]]; then
				myfiles+=("${myroot}/${1#/}")
			elif [[ -e "${myroot}/${1#/}" ]]; then
				eerror "${FUNCNAME}(): ${myroot}/${1#/} is not a regular file or directory"
			else
				eerror "${FUNCNAME}(): ${myroot}/${1#/} does not exist"
			fi
			shift
		done

		# set additional opts
		myopts+=(-q)

		PYTHON_ABI="${PYTHON_ABI:-$(PYTHON --ABI)}"

		ebegin "Byte-compilation of Python modules for $(python_get_implementation_and_version)"
		if ((${#mydirs[@]})); then
			"$(PYTHON ${PYTHON_ABI})" "${myroot}$(python_get_libdir)/compileall.py" "${myopts[@]}" "${mydirs[@]}" || return_code="1"
			"$(PYTHON ${PYTHON_ABI})" -O "${myroot}$(python_get_libdir)/compileall.py" "${myopts[@]}" "${mydirs[@]}" &> /dev/null || return_code="1"
			_python_clean_byte-compiled_modules "${mydirs[@]}"
		fi

		if ((${#myfiles[@]})); then
			"$(PYTHON ${PYTHON_ABI})" "${myroot}$(python_get_libdir)/py_compile.py" "${myfiles[@]}" || return_code="1"
			"$(PYTHON ${PYTHON_ABI})" -O "${myroot}$(python_get_libdir)/py_compile.py" "${myfiles[@]}" &> /dev/null || return_code="1"
			_python_clean_byte-compiled_modules "${myfiles[@]}"
		fi

		eend "${return_code}"
	fi
}

# @FUNCTION: python_clean_byte-compiled_modules
# @USAGE: [-A|--ABIs-patterns Python_ABIs] [--allow-evaluated-non-sitedir-paths] [--] <file|directory> [files|directories]
# @DESCRIPTION:
# Delete orphaned byte-compiled Python modules corresponding to specified Python modules.
#
# This function can be used only in pkg_postrm() phase.
python_clean_byte-compiled_modules() {
	if [[ "${EBUILD_PHASE}" != "postrm" ]]; then
		die "${FUNCNAME}() can be used only in pkg_postrm() phase"
	fi

	_python_check_python_pkg_setup_execution
	_python_initialize_prefix_variables

	local ABIs_patterns="*" allow_evaluated_non_sitedir_paths="0" dir enabled_PYTHON_ABI enabled_PYTHON_ABIS iterated_PYTHON_ABIS PYTHON_ABI="${PYTHON_ABI}" root search_paths=() sitedir

	if _python_abi_type single; then
		enabled_PYTHON_ABIS="${PYTHON_SINGLE_ABI}"
	elif _python_abi_type multiple; then
		if has "${EAPI:-0}" 0 1 2 3 && [[ -z "${PYTHON_ABIS}" ]]; then
			die "${FUNCNAME}(): python_pkg_setup() or python_execute_function() not called"
		fi
		enabled_PYTHON_ABIS="${PYTHON_ABIS}"
	else
		if has "${EAPI:-0}" 0 1 2 3; then
			enabled_PYTHON_ABIS="${PYTHON_ABI:-$(PYTHON --ABI)}"
		else
			enabled_PYTHON_ABIS="${PYTHON_ABI}"
		fi
	fi

	# Strip trailing slash from EROOT.
	root="${EROOT%/}"

	while (($#)); do
		case "$1" in
			-A|--ABIs-patterns)
				ABIs_patterns="$2"
				shift
				;;
			--allow-evaluated-non-sitedir-paths)
				allow_evaluated_non_sitedir_paths="1"
				;;
			--)
				shift
				break
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				break
				;;
		esac
		shift
	done

	if ! _python_abi_type multiple && [[ "${allow_evaluated_non_sitedir_paths}" == "1" ]]; then
		die "${FUNCNAME}(): '--allow-evaluated-non-sitedir-paths' option can not be used in ebuilds not setting PYTHON_ABI_TYPE=\"multiple\" variable"
	fi

	if [[ "$#" -eq 0 ]]; then
		die "${FUNCNAME}(): Missing files or directories"
	fi

	for enabled_PYTHON_ABI in ${enabled_PYTHON_ABIS}; do
		if _python_check_python_abi_matching --patterns-list "${enabled_PYTHON_ABI}" "${ABIs_patterns}"; then
			iterated_PYTHON_ABIS+="${iterated_PYTHON_ABIS:+ }${enabled_PYTHON_ABI}"
		fi
	done

	if ! has "${EAPI:-0}" 0 1 2 || _python_abi_type single || _python_abi_type multiple || _python_implementation || [[ "${CATEGORY}/${PN}" == "sys-apps/portage" ]]; then
		while (($#)); do
			if [[ "$1" =~ ^($|(\.|\.\.|/)($|/)) ]]; then
				die "${FUNCNAME}(): Invalid argument '$1'"
			elif ! _python_implementation && [[ "$1" =~ ^/usr/lib(32|64)?/python[[:digit:]]+\.[[:digit:]]+ ]]; then
				die "${FUNCNAME}(): Paths of directories / files in site-packages directories must be relative to site-packages directories"
			elif [[ "$1" =~ ^/ ]]; then
				if _python_abi_type multiple; then
					if [[ "${allow_evaluated_non_sitedir_paths}" != "1" ]]; then
						die "${FUNCNAME}(): Absolute paths can not be used in ebuilds setting PYTHON_ABI_TYPE=\"multiple\" variable"
					fi
					if [[ "$1" != *\$* ]]; then
						die "${FUNCNAME}(): '$1' has invalid syntax"
					fi
					for PYTHON_ABI in ${iterated_PYTHON_ABIS}; do
						eval "search_paths+=(\"\${root}$1\")"
					done
				else
					if [[ -n "${iterated_PYTHON_ABIS}" ]]; then
						search_paths+=("${root}$1")
					fi
				fi
			else
				for PYTHON_ABI in ${iterated_PYTHON_ABIS}; do
					search_paths+=("${root}$(python_get_sitedir)/$1")
				done
			fi
			shift
		done
	else
		# Deprecated part of python_clean_byte-compiled_modules()
		ewarn
		ewarn "Deprecation Warning: Usage of ${FUNCNAME}() in ebuilds not setting PYTHON_ABI_TYPE=\"single\""
		ewarn "or PYTHON_ABI_TYPE=\"multiple\" variable in EAPI <=2 is deprecated and will be disallowed on 2017-01-01."
		ewarn "Use EAPI >=3 and call ${FUNCNAME}() with paths having appropriate syntax."
		ewarn "The ebuild needs to be fixed. Please report a bug, if it has not been already reported."
		ewarn

		search_paths=("${@#/}")
		search_paths=("${search_paths[@]/#/${root}/}")
	fi

	_python_clean_byte-compiled_modules "${search_paths[@]}"
}

# ========================================================================================================================
# ======================================== FUNCTIONS FOR HANDLING OF CFFI MODULES ========================================
# ========================================================================================================================

# @ECLASS-VARIABLE: PYTHON_CFFI_MODULES_GENERATION_COMMANDS
# @DESCRIPTION:
# Array of Python commands used for generation of Python CFFI modules.

# @FUNCTION: python_generate_cffi_modules
# @USAGE: [-A|--ABIs-patterns Python_ABIs]
# @DESCRIPTION:
# Generate Python CFFI modules.
#
# This function can be used only in src_install() phase.
python_generate_cffi_modules() {
	if has "${EAPI:-0}" 0 1 2 3; then
		die "${FUNCNAME}() can not be used in EAPI=\"${EAPI}\""
	fi

	if [[ "${EBUILD_PHASE}" != "install" ]]; then
		die "${FUNCNAME}() can be used only in src_install() phase"
	fi

	_python_check_python_pkg_setup_execution
	_python_set_color_variables

	local ABIs_patterns="*" enabled_PYTHON_ABI enabled_PYTHON_ABIS iterated_PYTHON_ABIS PYTHON_ABI="${PYTHON_ABI}" python_command

	if _python_abi_type single; then
		enabled_PYTHON_ABIS="${PYTHON_SINGLE_ABI}"
	elif _python_abi_type multiple; then
		enabled_PYTHON_ABIS="${PYTHON_ABIS}"
	else
		enabled_PYTHON_ABIS="${PYTHON_ABI}"
	fi

	while (($#)); do
		case "$1" in
			-A|--ABIs-patterns)
				ABIs_patterns="$2"
				shift
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				die "${FUNCNAME}(): Invalid usage"
				;;
		esac
		shift
	done

	for enabled_PYTHON_ABI in ${enabled_PYTHON_ABIS}; do
		if _python_check_python_abi_matching --patterns-list "${enabled_PYTHON_ABI}" "${ABIs_patterns}"; then
			iterated_PYTHON_ABIS+="${iterated_PYTHON_ABIS:+ }${enabled_PYTHON_ABI}"
		fi
	done

	if [[ "${#PYTHON_CFFI_MODULES_GENERATION_COMMANDS[@]}" -ge 1 ]]; then
		_python_clean_cffi_modules --delete-cffi-modules

		for PYTHON_ABI in ${iterated_PYTHON_ABIS}; do
			echo " ${_GREEN}*${_NORMAL} ${_BLUE}Generation of Python CFFI modules for $(python_get_implementation_and_version)${_NORMAL}"
			for python_command in "${PYTHON_CFFI_MODULES_GENERATION_COMMANDS[@]}"; do
				echo "${_BOLD}\"${python_command}\"${_NORMAL}"

				pushd "${T}" > /dev/null || die "pushd failed"

				_python_execute_with_build_environment --verbose-executables "$(PYTHON ${PYTHON_ABI})" -c \
"import sys
sys.path.remove('')
sys.path.insert(0, '${ED}$(python_get_sitedir -b)')
del sys

${python_command}" || die "Generation of Python CFFI modules for $(python_get_implementation_and_version) failed"

				popd > /dev/null || die "popd failed"
			done
		done

		_python_clean_cffi_modules
	fi
}

_python_clean_cffi_modules() {
	if has "${EAPI:-0}" 0 1 2 3; then
		die "${FUNCNAME}() can not be used in EAPI=\"${EAPI}\""
	fi

	if [[ "${EBUILD_PHASE}" != "install" ]]; then
		die "${FUNCNAME}() can be used only in src_install() phase"
	fi

	_python_check_python_pkg_setup_execution

	local cache_directory delete_cffi_modules="0" file

	while (($#)); do
		case "$1" in
			--delete-cffi-modules)
				delete_cffi_modules="1"
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				die "${FUNCNAME}(): Invalid usage"
				;;
		esac
		shift
	done

	while IFS="" read -d "" -r cache_directory; do
		if [[ -d "${cache_directory}" ]]; then
			pushd "${cache_directory}" > /dev/null || die "pushd failed"
			for file in *; do
				if [[ -d "${file}" ]]; then
					rm -r "${file}" || die "${FUNCNAME}(): Deletion of '${file}' failed"
				elif [[ -f "${file}" ]]; then
					if [[ "${file}" == *.c ]]; then
						rm "${file}" || die "${FUNCNAME}(): Deletion of '${file}' failed"
					elif [[ "${delete_cffi_modules}" == "1" && "${file}" == *.so ]]; then
						rm "${file}" || die "${FUNCNAME}(): Deletion of '${file}' failed"
					fi
				fi
			done
			popd > /dev/null || die "popd failed"
		fi
	done < <(find "${ED}" -name "__pycache__" -type d -print0)
}

# ========================================================================================================================
# ================================================= DEPRECATED FUNCTIONS =================================================
# ========================================================================================================================

# Scheduled for deletion on 2017-01-01.
python_enable_pyc() {
	python_enable_byte-compilation "$@"
}

# Scheduled for deletion on 2017-01-01.
python_disable_pyc() {
	python_disable_byte-compilation "$@"
}

# Scheduled for deletion on 2017-01-01.
python_mod_optimize() {
	python_byte-compile_modules "$@"
}

# Scheduled for deletion on 2017-01-01.
python_mod_cleanup() {
	python_clean_byte-compiled_modules "$@"
}
