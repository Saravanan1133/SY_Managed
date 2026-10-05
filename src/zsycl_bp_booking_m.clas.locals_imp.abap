CLASS lhc_zsy_i_booking_m DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS earlynumbering_cba_Bookingsupp FOR NUMBERING
       entities FOR CREATE zsy_i_booking_m\_Bookingsuppl.
    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR zsy_i_booking_m RESULT result.
    METHODS determinetotalprice FOR DETERMINE ON MODIFY
      keys FOR zsy_i_booking_m~determinetotalprice.

ENDCLASS.

CLASS lhc_zsy_i_booking_m IMPLEMENTATION.

  METHOD earlynumbering_cba_Bookingsupp.

    DATA: lt_keys        TYPE TABLE FOR READ IMPORT zsy_i_booking_m\_BookingSuppl,
          lv_max_supp_id TYPE /dmo/booking_supplement_id.

    lt_keys = CORRESPONDING #( entities ).

    READ ENTITIES OF zsy_i_travel_m IN LOCAL MODE ENTITY zsy_i_booking_m BY \_BookingSuppl
    FROM lt_keys RESULT DATA(lt_existing_booksuppls) FAILED DATA(lt_failed).

    IF lt_failed-zsy_i_booksuppl_m IS INITIAL.


      LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_group>) GROUP BY ( travelid = <fs_group>-TravelId
                                                                    bookingid = <fs_group>-BookingId ).

        CLEAR lv_max_supp_id.

        LOOP AT lt_existing_booksuppls INTO DATA(ls_exs_booksuppls) USING KEY entity WHERE %key-TravelId = <fs_group>-TravelId
                                                                                      AND %key-BookingId = <fs_group>-BookingId.

          IF ls_exs_booksuppls-BookingSupplementId > lv_max_supp_id.
            lv_max_supp_id = ls_exs_booksuppls-BookingSupplementId.
          ENDIF.


        ENDLOOP.

        LOOP AT GROUP <fs_group> ASSIGNING FIELD-SYMBOL(<fs_entity>).

          LOOP AT <fs_entity>-%target INTO DATA(ls_target) WHERE BookingSupplementId IS NOT INITIAL.

            IF ls_target-BookingSupplementId > lv_max_supp_id.
              lv_max_supp_id = ls_target-BookingSupplementId.
            ENDIF.

          ENDLOOP.

        ENDLOOP.

        LOOP AT <fs_entity>-%target INTO ls_target.

          APPEND CORRESPONDING #( ls_target ) TO mapped-zsy_i_booksuppl_m ASSIGNING FIELD-SYMBOL(<fs_mapped>).

          IF ls_target-BookingSupplementId IS INITIAL.
            lv_max_supp_id += 1.
            <fs_mapped>-BookingSupplementId = lv_max_supp_id.
          ENDIF.

        ENDLOOP.


      ENDLOOP.

    ENDIF.


  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zsy_i_travel_m IN LOCAL MODE
    ENTITY zsy_i_travel_m BY \_Booking FIELDS ( TravelId BookingId BookingStatus )
    WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).

    result = VALUE #( FOR ls_res IN lt_result
                    ( %tky = ls_res-%tky
                      %features-%assoc-_BookingSuppl = COND #( WHEN ls_res-BookingStatus = 'X'
                                                               THEN if_Abap_behv=>fc-o-disabled
                                                               ELSE if_Abap_behv=>fc-o-enabled ) )
                      ).

  ENDMETHOD.

  METHOD determineTotalPrice.
  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

