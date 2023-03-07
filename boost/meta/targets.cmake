if(NOT TARGET boost::accumulators)
    add_library(boost::accumulators INTERFACE IMPORTED)
    set_target_properties(boost::accumulators PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::algorithm)
    add_library(boost::algorithm INTERFACE IMPORTED)
    set_target_properties(boost::algorithm PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::align)
    add_library(boost::align INTERFACE IMPORTED)
    set_target_properties(boost::align PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::any)
    add_library(boost::any INTERFACE IMPORTED)
    set_target_properties(boost::any PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::array)
    add_library(boost::array INTERFACE IMPORTED)
    set_target_properties(boost::array PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::asio)
    add_library(boost::asio INTERFACE IMPORTED)
    set_target_properties(boost::asio PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::assert)
    add_library(boost::assert INTERFACE IMPORTED)
    set_target_properties(boost::assert PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::assign)
    add_library(boost::assign INTERFACE IMPORTED)
    set_target_properties(boost::assign PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::beast)
    add_library(boost::beast INTERFACE IMPORTED)
    set_target_properties(boost::beast PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::bimap)
    add_library(boost::bimap INTERFACE IMPORTED)
    set_target_properties(boost::bimap PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::bind)
    add_library(boost::bind INTERFACE IMPORTED)
    set_target_properties(boost::bind PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::callable_traits)
    add_library(boost::callable_traits INTERFACE IMPORTED)
    set_target_properties(boost::callable_traits PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::chrono_stopwatches)
    add_library(boost::chrono_stopwatches INTERFACE IMPORTED)
    set_target_properties(boost::chrono_stopwatches PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::circular_buffer)
    add_library(boost::circular_buffer INTERFACE IMPORTED)
    set_target_properties(boost::circular_buffer PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::compatibility)
    add_library(boost::compatibility INTERFACE IMPORTED)
    set_target_properties(boost::compatibility PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::compute)
    add_library(boost::compute INTERFACE IMPORTED)
    set_target_properties(boost::compute PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::concept_check)
    add_library(boost::concept_check INTERFACE IMPORTED)
    set_target_properties(boost::concept_check PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::config)
    add_library(boost::config INTERFACE IMPORTED)
    set_target_properties(boost::config PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::container_hash)
    add_library(boost::container_hash INTERFACE IMPORTED)
    set_target_properties(boost::container_hash PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::conversion)
    add_library(boost::conversion INTERFACE IMPORTED)
    set_target_properties(boost::conversion PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::convert)
    add_library(boost::convert INTERFACE IMPORTED)
    set_target_properties(boost::convert PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::core)
    add_library(boost::core INTERFACE IMPORTED)
    set_target_properties(boost::core PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::coroutine2)
    add_library(boost::coroutine2 INTERFACE IMPORTED)
    set_target_properties(boost::coroutine2 PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::crc)
    add_library(boost::crc INTERFACE IMPORTED)
    set_target_properties(boost::crc PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::detail)
    add_library(boost::detail INTERFACE IMPORTED)
    set_target_properties(boost::detail PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::disjoint_sets)
    add_library(boost::disjoint_sets INTERFACE IMPORTED)
    set_target_properties(boost::disjoint_sets PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::dll)
    add_library(boost::dll INTERFACE IMPORTED)
    set_target_properties(boost::dll PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::dynamic_bitset)
    add_library(boost::dynamic_bitset INTERFACE IMPORTED)
    set_target_properties(boost::dynamic_bitset PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::endian)
    add_library(boost::endian INTERFACE IMPORTED)
    set_target_properties(boost::endian PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::flyweight)
    add_library(boost::flyweight INTERFACE IMPORTED)
    set_target_properties(boost::flyweight PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::foreach)
    add_library(boost::foreach INTERFACE IMPORTED)
    set_target_properties(boost::foreach PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::format)
    add_library(boost::format INTERFACE IMPORTED)
    set_target_properties(boost::format PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::function)
    add_library(boost::function INTERFACE IMPORTED)
    set_target_properties(boost::function PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::function_types)
    add_library(boost::function_types INTERFACE IMPORTED)
    set_target_properties(boost::function_types PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::functional)
    add_library(boost::functional INTERFACE IMPORTED)
    set_target_properties(boost::functional PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::fusion)
    add_library(boost::fusion INTERFACE IMPORTED)
    set_target_properties(boost::fusion PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::geometry)
    add_library(boost::geometry INTERFACE IMPORTED)
    set_target_properties(boost::geometry PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::gil)
    add_library(boost::gil INTERFACE IMPORTED)
    set_target_properties(boost::gil PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::hana)
    add_library(boost::hana INTERFACE IMPORTED)
    set_target_properties(boost::hana PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::heap)
    add_library(boost::heap INTERFACE IMPORTED)
    set_target_properties(boost::heap PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::hof)
    add_library(boost::hof INTERFACE IMPORTED)
    set_target_properties(boost::hof PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::icl)
    add_library(boost::icl INTERFACE IMPORTED)
    set_target_properties(boost::icl PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::integer)
    add_library(boost::integer INTERFACE IMPORTED)
    set_target_properties(boost::integer PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::interprocess)
    add_library(boost::interprocess INTERFACE IMPORTED)
    set_target_properties(boost::interprocess PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::intrusive)
    add_library(boost::intrusive INTERFACE IMPORTED)
    set_target_properties(boost::intrusive PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::io)
    add_library(boost::io INTERFACE IMPORTED)
    set_target_properties(boost::io PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::iterator)
    add_library(boost::iterator INTERFACE IMPORTED)
    set_target_properties(boost::iterator PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::lambda)
    add_library(boost::lambda INTERFACE IMPORTED)
    set_target_properties(boost::lambda PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::lexical_cast)
    add_library(boost::lexical_cast INTERFACE IMPORTED)
    set_target_properties(boost::lexical_cast PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::local_function)
    add_library(boost::local_function INTERFACE IMPORTED)
    set_target_properties(boost::local_function PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::lockfree)
    add_library(boost::lockfree INTERFACE IMPORTED)
    set_target_properties(boost::lockfree PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::logic)
    add_library(boost::logic INTERFACE IMPORTED)
    set_target_properties(boost::logic PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::metaparse)
    add_library(boost::metaparse INTERFACE IMPORTED)
    set_target_properties(boost::metaparse PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::move)
    add_library(boost::move INTERFACE IMPORTED)
    set_target_properties(boost::move PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::mp11)
    add_library(boost::mp11 INTERFACE IMPORTED)
    set_target_properties(boost::mp11 PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::mpl)
    add_library(boost::mpl INTERFACE IMPORTED)
    set_target_properties(boost::mpl PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::msm)
    add_library(boost::msm INTERFACE IMPORTED)
    set_target_properties(boost::msm PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::multi_array)
    add_library(boost::multi_array INTERFACE IMPORTED)
    set_target_properties(boost::multi_array PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::multi_index)
    add_library(boost::multi_index INTERFACE IMPORTED)
    set_target_properties(boost::multi_index PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::multiprecision)
    add_library(boost::multiprecision INTERFACE IMPORTED)
    set_target_properties(boost::multiprecision PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::numeric_conversion)
    add_library(boost::numeric_conversion INTERFACE IMPORTED)
    set_target_properties(boost::numeric_conversion PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::numeric_interval)
    add_library(boost::numeric_interval INTERFACE IMPORTED)
    set_target_properties(boost::numeric_interval PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::numeric_odeint)
    add_library(boost::numeric_odeint INTERFACE IMPORTED)
    set_target_properties(boost::numeric_odeint PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::numeric_ublas)
    add_library(boost::numeric_ublas INTERFACE IMPORTED)
    set_target_properties(boost::numeric_ublas PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::optional)
    add_library(boost::optional INTERFACE IMPORTED)
    set_target_properties(boost::optional PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::parameter)
    add_library(boost::parameter INTERFACE IMPORTED)
    set_target_properties(boost::parameter PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::phoenix)
    add_library(boost::phoenix INTERFACE IMPORTED)
    set_target_properties(boost::phoenix PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::poly_collection)
    add_library(boost::poly_collection INTERFACE IMPORTED)
    set_target_properties(boost::poly_collection PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::polygon)
    add_library(boost::polygon INTERFACE IMPORTED)
    set_target_properties(boost::polygon PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::pool)
    add_library(boost::pool INTERFACE IMPORTED)
    set_target_properties(boost::pool PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::predef)
    add_library(boost::predef INTERFACE IMPORTED)
    set_target_properties(boost::predef PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::preprocessor)
    add_library(boost::preprocessor INTERFACE IMPORTED)
    set_target_properties(boost::preprocessor PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::process)
    add_library(boost::process INTERFACE IMPORTED)
    set_target_properties(boost::process PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::property_map)
    add_library(boost::property_map INTERFACE IMPORTED)
    set_target_properties(boost::property_map PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::property_tree)
    add_library(boost::property_tree INTERFACE IMPORTED)
    set_target_properties(boost::property_tree PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::proto)
    add_library(boost::proto INTERFACE IMPORTED)
    set_target_properties(boost::proto PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::ptr_container)
    add_library(boost::ptr_container INTERFACE IMPORTED)
    set_target_properties(boost::ptr_container PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::qvm)
    add_library(boost::qvm INTERFACE IMPORTED)
    set_target_properties(boost::qvm PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::range)
    add_library(boost::range INTERFACE IMPORTED)
    set_target_properties(boost::range PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::ratio)
    add_library(boost::ratio INTERFACE IMPORTED)
    set_target_properties(boost::ratio PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::rational)
    add_library(boost::rational INTERFACE IMPORTED)
    set_target_properties(boost::rational PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::scope_exit)
    add_library(boost::scope_exit INTERFACE IMPORTED)
    set_target_properties(boost::scope_exit PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::signals2)
    add_library(boost::signals2 INTERFACE IMPORTED)
    set_target_properties(boost::signals2 PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::smart_ptr)
    add_library(boost::smart_ptr INTERFACE IMPORTED)
    set_target_properties(boost::smart_ptr PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::sort)
    add_library(boost::sort INTERFACE IMPORTED)
    set_target_properties(boost::sort PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::spirit)
    add_library(boost::spirit INTERFACE IMPORTED)
    set_target_properties(boost::spirit PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::statechart)
    add_library(boost::statechart INTERFACE IMPORTED)
    set_target_properties(boost::statechart PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::static_assert)
    add_library(boost::static_assert INTERFACE IMPORTED)
    set_target_properties(boost::static_assert PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::throw_exception)
    add_library(boost::throw_exception INTERFACE IMPORTED)
    set_target_properties(boost::throw_exception PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::tokenizer)
    add_library(boost::tokenizer INTERFACE IMPORTED)
    set_target_properties(boost::tokenizer PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::tti)
    add_library(boost::tti INTERFACE IMPORTED)
    set_target_properties(boost::tti PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::tuple)
    add_library(boost::tuple INTERFACE IMPORTED)
    set_target_properties(boost::tuple PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::type_index)
    add_library(boost::type_index INTERFACE IMPORTED)
    set_target_properties(boost::type_index PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::type_traits)
    add_library(boost::type_traits INTERFACE IMPORTED)
    set_target_properties(boost::type_traits PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::typeof)
    add_library(boost::typeof INTERFACE IMPORTED)
    set_target_properties(boost::typeof PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::units)
    add_library(boost::units INTERFACE IMPORTED)
    set_target_properties(boost::units PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::unordered)
    add_library(boost::unordered INTERFACE IMPORTED)
    set_target_properties(boost::unordered PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::utility)
    add_library(boost::utility INTERFACE IMPORTED)
    set_target_properties(boost::utility PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::uuid)
    add_library(boost::uuid INTERFACE IMPORTED)
    set_target_properties(boost::uuid PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::variant)
    add_library(boost::variant INTERFACE IMPORTED)
    set_target_properties(boost::variant PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::vmd)
    add_library(boost::vmd INTERFACE IMPORTED)
    set_target_properties(boost::vmd PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::winapi)
    add_library(boost::winapi INTERFACE IMPORTED)
    set_target_properties(boost::winapi PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::xpressive)
    add_library(boost::xpressive INTERFACE IMPORTED)
    set_target_properties(boost::xpressive PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::yap)
    add_library(boost::yap INTERFACE IMPORTED)
    set_target_properties(boost::yap PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::math)
    add_library(boost::math INTERFACE IMPORTED)
    set_target_properties(boost::math PROPERTIES
        INTERFACE_LINK_LIBRARIES "boost::math_c99;boost::math_c99f;boost::math_c99l;boost::math_tr1;boost::math_tr1f;boost::math_tr1l"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()

if(NOT TARGET boost::atomic AND EXISTS ${_DEP_LIB_DIR}/libboost_atomic.a)
    add_library(boost::atomic STATIC IMPORTED)
    set_target_properties(boost::atomic PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_atomic.a"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::chrono AND EXISTS ${_DEP_LIB_DIR}/libboost_chrono.a)
    add_library(boost::chrono STATIC IMPORTED)
    set_target_properties(boost::chrono PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_chrono.a"
        INTERFACE_LINK_LIBRARIES "boost::system"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::container AND EXISTS ${_DEP_LIB_DIR}/libboost_container.a)
    add_library(boost::container STATIC IMPORTED)
    set_target_properties(boost::container PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_container.a"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::context AND EXISTS ${_DEP_LIB_DIR}/libboost_context.a)
    add_library(boost::context STATIC IMPORTED)
    set_target_properties(boost::context PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_context.a"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::contract AND EXISTS ${_DEP_LIB_DIR}/libboost_contract.a)
    add_library(boost::contract STATIC IMPORTED)
    set_target_properties(boost::contract PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_contract.a"
        INTERFACE_LINK_LIBRARIES "boost::exception;boost::thread"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::coroutine AND EXISTS ${_DEP_LIB_DIR}/libboost_coroutine.a)
    add_library(boost::coroutine STATIC IMPORTED)
    set_target_properties(boost::coroutine PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_coroutine.a"
        INTERFACE_LINK_LIBRARIES "boost::context;boost::exception;boost::system"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::date_time AND EXISTS ${_DEP_LIB_DIR}/libboost_date_time.a)
    add_library(boost::date_time STATIC IMPORTED)
    set_target_properties(boost::date_time PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_date_time.a"
        INTERFACE_LINK_LIBRARIES "boost::serialization"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::exception AND EXISTS ${_DEP_LIB_DIR}/libboost_exception.a)
    add_library(boost::exception STATIC IMPORTED)
    set_target_properties(boost::exception PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_exception.a"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::fiber AND EXISTS ${_DEP_LIB_DIR}/libboost_fiber.a)
    add_library(boost::fiber STATIC IMPORTED)
    set_target_properties(boost::fiber PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_fiber.a"
        INTERFACE_LINK_LIBRARIES "boost::context"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::filesystem AND EXISTS ${_DEP_LIB_DIR}/libboost_filesystem.a)
    add_library(boost::filesystem STATIC IMPORTED)
    set_target_properties(boost::filesystem PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_filesystem.a"
        INTERFACE_LINK_LIBRARIES "boost::system"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::graph AND EXISTS ${_DEP_LIB_DIR}/libboost_graph.a)
    add_library(boost::graph STATIC IMPORTED)
    set_target_properties(boost::graph PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_graph.a"
        INTERFACE_LINK_LIBRARIES "boost::graph_parallel;boost::math;boost::random;boost::serialization;boost::test"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::graph_parallel AND EXISTS ${_DEP_LIB_DIR}/libboost_graph_parallel.a)
    add_library(boost::graph_parallel STATIC IMPORTED)
    set_target_properties(boost::graph_parallel PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_graph_parallel.a"
        INTERFACE_LINK_LIBRARIES "boost::filesystem;boost::graph;boost::mpi;boost::random;boost::serialization"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::iostreams AND EXISTS ${_DEP_LIB_DIR}/libboost_iostreams.a)
    add_library(boost::iostreams STATIC IMPORTED)
    set_target_properties(boost::iostreams PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_iostreams.a"
        INTERFACE_LINK_LIBRARIES "boost::random;boost::regex"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::locale AND EXISTS ${_DEP_LIB_DIR}/libboost_locale.a)
    add_library(boost::locale STATIC IMPORTED)
    set_target_properties(boost::locale PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_locale.a"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::log AND EXISTS ${_DEP_LIB_DIR}/libboost_log.a)
    add_library(boost::log STATIC IMPORTED)
    set_target_properties(boost::log PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_log.a"
        INTERFACE_LINK_LIBRARIES "boost::atomic;boost::container;boost::date_time;boost::exception;boost::filesystem;boost::locale;boost::regex;boost::system;boost::thread"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::math_c99 AND EXISTS ${_DEP_LIB_DIR}/libboost_math_c99.a)
    add_library(boost::math_c99 STATIC IMPORTED)
    set_target_properties(boost::math_c99 PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_math_c99.a"
        INTERFACE_LINK_LIBRARIES "boost::atomic"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::math_c99f AND EXISTS ${_DEP_LIB_DIR}/libboost_math_c99f.a)
    add_library(boost::math_c99f STATIC IMPORTED)
    set_target_properties(boost::math_c99f PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_math_c99f.a"
        INTERFACE_LINK_LIBRARIES "boost::atomic"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::math_c99l AND EXISTS ${_DEP_LIB_DIR}/libboost_math_c99l.a)
    add_library(boost::math_c99l STATIC IMPORTED)
    set_target_properties(boost::math_c99l PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_math_c99l.a"
        INTERFACE_LINK_LIBRARIES "boost::atomic"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::math_tr1 AND EXISTS ${_DEP_LIB_DIR}/libboost_math_tr1.a)
    add_library(boost::math_tr1 STATIC IMPORTED)
    set_target_properties(boost::math_tr1 PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_math_tr1.a"
        INTERFACE_LINK_LIBRARIES "boost::atomic"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::math_tr1f AND EXISTS ${_DEP_LIB_DIR}/libboost_math_tr1f.a)
    add_library(boost::math_tr1f STATIC IMPORTED)
    set_target_properties(boost::math_tr1f PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_math_tr1f.a"
        INTERFACE_LINK_LIBRARIES "boost::atomic"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::math_tr1l AND EXISTS ${_DEP_LIB_DIR}/libboost_math_tr1l.a)
    add_library(boost::math_tr1l STATIC IMPORTED)
    set_target_properties(boost::math_tr1l PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_math_tr1l.a"
        INTERFACE_LINK_LIBRARIES "boost::atomic"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::mpi AND EXISTS ${_DEP_LIB_DIR}/libboost_mpi.a)
    add_library(boost::mpi STATIC IMPORTED)
    set_target_properties(boost::mpi PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_mpi.a"
        INTERFACE_LINK_LIBRARIES "boost::graph;boost::python2;boost::serialization"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::program_options AND EXISTS ${_DEP_LIB_DIR}/libboost_program_options.a)
    add_library(boost::program_options STATIC IMPORTED)
    set_target_properties(boost::program_options PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_program_options.a"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::python2 AND EXISTS ${_DEP_LIB_DIR}/libboost_python2.a)
    add_library(boost::python2 STATIC IMPORTED)
    set_target_properties(boost::python2 PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_python2.a"
        INTERFACE_LINK_LIBRARIES "python2::libpython"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::python3 AND EXISTS ${_DEP_LIB_DIR}/libboost_python3.a)
    add_library(boost::python3 STATIC IMPORTED)
    set_target_properties(boost::python3 PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_python3.a"
        INTERFACE_LINK_LIBRARIES "python3::libpython"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::numpy2 AND EXISTS ${_DEP_LIB_DIR}/libboost_numpy2.a)
    add_library(boost::numpy2 STATIC IMPORTED)
    set_target_properties(boost::numpy2 PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_numpy2.a"
        INTERFACE_LINK_LIBRARIES "boost::python2"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::numpy3 AND EXISTS ${_DEP_LIB_DIR}/libboost_numpy3.a)
    add_library(boost::numpy3 STATIC IMPORTED)
    set_target_properties(boost::numpy3 PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_numpy3.a"
        INTERFACE_LINK_LIBRARIES "boost::python3"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::random AND EXISTS ${_DEP_LIB_DIR}/libboost_random.a)
    add_library(boost::random STATIC IMPORTED)
    set_target_properties(boost::random PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_random.a"
        INTERFACE_LINK_LIBRARIES "boost::math;boost::system"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::regex AND EXISTS ${_DEP_LIB_DIR}/libboost_regex.a)
    add_library(boost::regex STATIC IMPORTED)
    set_target_properties(boost::regex PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_regex.a"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::serialization AND EXISTS ${_DEP_LIB_DIR}/libboost_serialization.a)
    add_library(boost::serialization STATIC IMPORTED)
    set_target_properties(boost::serialization PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_serialization.a"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::signals AND EXISTS ${_DEP_LIB_DIR}/libboost_signals.a)
    add_library(boost::signals STATIC IMPORTED)
    set_target_properties(boost::signals PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_signals.a"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::stacktrace_addr2line AND EXISTS ${_DEP_LIB_DIR}/libboost_stacktrace_addr2line.a)
    add_library(boost::stacktrace_addr2line STATIC IMPORTED)
    set_target_properties(boost::stacktrace_addr2line PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_stacktrace_addr2line.a"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::stacktrace_basic AND EXISTS ${_DEP_LIB_DIR}/libboost_stacktrace_basic.a)
    add_library(boost::stacktrace_basic STATIC IMPORTED)
    set_target_properties(boost::stacktrace_basic PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_stacktrace_basic.a"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::stacktrace_noop AND EXISTS ${_DEP_LIB_DIR}/libboost_stacktrace_noop.a)
    add_library(boost::stacktrace_noop STATIC IMPORTED)
    set_target_properties(boost::stacktrace_noop PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_stacktrace_noop.a"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::system AND EXISTS ${_DEP_LIB_DIR}/libboost_system.a)
    add_library(boost::system STATIC IMPORTED)
    set_target_properties(boost::system PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_system.a"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::test AND EXISTS ${_DEP_LIB_DIR}/libboost_test.a)
    add_library(boost::test STATIC IMPORTED)
    set_target_properties(boost::test PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_test.a"
        INTERFACE_LINK_LIBRARIES "boost::exception;boost::timer"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::thread AND EXISTS ${_DEP_LIB_DIR}/libboost_thread.a)
    add_library(boost::thread STATIC IMPORTED)
    set_target_properties(boost::thread PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_thread.a"
        INTERFACE_LINK_LIBRARIES "boost::atomic;boost::chrono;boost::container;boost::date_time;boost::exception;boost::system;pthread"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}"
        INTERFACE_COMPILE_OPTIONS "-pthread")
endif()
if(NOT TARGET boost::timer AND EXISTS ${_DEP_LIB_DIR}/libboost_timer.a)
    add_library(boost::timer STATIC IMPORTED)
    set_target_properties(boost::timer PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_timer.a"
        INTERFACE_LINK_LIBRARIES "boost::system"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::type_erasure AND EXISTS ${_DEP_LIB_DIR}/libboost_type_erasure.a)
    add_library(boost::type_erasure STATIC IMPORTED)
    set_target_properties(boost::type_erasure PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_type_erasure.a"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET boost::wave AND EXISTS ${_DEP_LIB_DIR}/libboost_wave.a)
    add_library(boost::wave STATIC IMPORTED)
    set_target_properties(boost::wave PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libboost_wave.a"
        INTERFACE_LINK_LIBRARIES "boost::filesystem;boost::serialization"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
