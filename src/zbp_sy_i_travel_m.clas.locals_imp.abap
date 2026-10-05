CLASS lsc_ZSY_I_TRAVEL_M DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZSY_I_TRAVEL_M IMPLEMENTATION.

  METHOD save_modified.

**// Local data declaration
    DATA: lt_travel_log TYPE TABLE OF zsy_travel_log,
          lt_booksuppl  TYPE TABLE OF zsy_booksuppl_m.

    IF create-zsy_i_travel_m IS NOT INITIAL.

      LOOP AT create-zsy_i_travel_m INTO DATA(ls_group) GROUP BY ls_Group-TravelId.

        READ TABLE create-zsy_i_travel_m INTO DATA(ls_create_travel) WITH KEY entity COMPONENTS TravelId = ls_group-TravelId.
        IF  sy-subrc = 0.

          IF ls_create_travel-%control-CustomerId = if_abap_behv=>mk-on.

            APPEND INITIAL LINE TO lt_travel_log ASSIGNING FIELD-SYMBOL(<fs_log>).
            IF <fs_log> IS ASSIGNED.

              TRY.
                  <fs_log>-change_id          = cl_system_uuid=>create_uuid_x16_static( ).
                CATCH cx_uuid_error.
              ENDTRY.

              <fs_log>-travelid = ls_group-TravelId.
              <Fs_log>-changing_operation = 'CREATE'.
              <fs_log>-changed_field_name = 'CUSTOMER'.
              <fs_log>-changed_value      = ls_create_travel-CustomerId.
              GET TIME STAMP FIELD <fs_log>-created_at.

              UNASSIGN <fs_log>.
            ENDIF.

          ENDIF.

          IF ls_create_travel-%control-Status = if_abap_behv=>mk-on.

            APPEND INITIAL LINE TO lt_travel_log ASSIGNING <fs_log>.
            IF <fs_log> IS ASSIGNED.

              TRY.
                  <fs_log>-change_id          = cl_system_uuid=>create_uuid_x16_static( ).
                CATCH cx_uuid_error.
              ENDTRY.

              <fs_log>-travelid = ls_group-TravelId.
              <Fs_log>-changing_operation = 'CREATE'.
              <fs_log>-changed_field_name = 'STATUS'.
              <fs_log>-changed_value      = ls_create_travel-Status.
              GET TIME STAMP FIELD <fs_log>-created_at.

              UNASSIGN <fs_log>.
            ENDIF.

          ENDIF.

        ENDIF.

      ENDLOOP.

      IF lt_travel_log IS NOT INITIAL.
        INSERT zsy_travel_log FROM TABLE @lt_travel_log.
      ENDIF.

    ENDIF.

    IF update-zsy_i_travel_m IS NOT INITIAL.

      LOOP AT update-zsy_i_travel_m INTO ls_group GROUP BY ls_Group-TravelId.

        READ TABLE update-zsy_i_travel_m INTO DATA(ls_update_travel) WITH KEY entity COMPONENTS TravelId = ls_group-TravelId.
        IF  sy-subrc = 0.

          IF ls_update_travel-%control-CustomerId = if_abap_behv=>mk-on.

            APPEND INITIAL LINE TO lt_travel_log ASSIGNING <fs_log>.
            IF <fs_log> IS ASSIGNED.

              TRY.
                  <fs_log>-change_id          = cl_system_uuid=>create_uuid_x16_static( ).
                CATCH cx_uuid_error.
              ENDTRY.

              <fs_log>-travelid = ls_group-TravelId.
              <Fs_log>-changing_operation = 'UPDATE'.
              <fs_log>-changed_field_name = 'CUSTOMER'.
              <fs_log>-changed_value      = ls_update_travel-CustomerId.
              GET TIME STAMP FIELD <fs_log>-created_at.

              UNASSIGN <fs_log>.
            ENDIF.

          ENDIF.

          IF ls_update_travel-%control-Status = if_abap_behv=>mk-on.

            APPEND INITIAL LINE TO lt_travel_log ASSIGNING <fs_log>.
            IF <fs_log> IS ASSIGNED.

              TRY.
                  <fs_log>-change_id          = cl_system_uuid=>create_uuid_x16_static( ).
                CATCH cx_uuid_error.
              ENDTRY.

              <fs_log>-travelid = ls_group-TravelId.
              <Fs_log>-changing_operation = 'UPDATE'.
              <fs_log>-changed_field_name = 'STATUS'.
              <fs_log>-changed_value      = ls_update_travel-Status.
              GET TIME STAMP FIELD <fs_log>-created_at.

              UNASSIGN <fs_log>.
            ENDIF.

          ENDIF.

        ENDIF.

      ENDLOOP.

      IF lt_travel_log IS NOT INITIAL.
        INSERT zsy_travel_log FROM TABLE @lt_travel_log.
      ENDIF.

    ENDIF.

    IF delete-zsy_i_travel_m IS NOT INITIAL.

      LOOP AT delete-zsy_i_travel_m INTO DATA(ls_del_group) GROUP BY ls_Group-TravelId.

        APPEND INITIAL LINE TO lt_travel_log ASSIGNING <fs_log>.
        IF <fs_log> IS ASSIGNED.

          <fs_log>-travelid = ls_group-TravelId.
          <Fs_log>-changing_operation = 'DELETE'.
          GET TIME STAMP FIELD <fs_log>-created_at.

          UNASSIGN <fs_log>.
        ENDIF.

      ENDLOOP.

      IF lt_travel_log IS NOT INITIAL.
        INSERT zsy_travel_log FROM TABLE @lt_travel_log.
      ENDIF.

    ENDIF.

    IF create-zsy_i_booksuppl_m IS NOT INITIAL.

      lt_booksuppl = VALUE #( FOR ls_crt_bsupl IN create-zsy_i_booksuppl_m
                        ( travel_id  = ls_crt_bsupl-TravelId
                          booking_id = ls_crt_bsupl-BookingId
                          booking_supplement_id = ls_crt_bsupl-BookingSupplementId
                          supplement_id         = ls_crt_bsupl-SupplementId
                          price                 = ls_crt_bsupl-Price
                          currency_code         = ls_crt_bsupl-CurrencyCode
                          last_changed_at       = ls_crt_bsupl-LastChangedAt ) ).

      INSERT zsy_booksuppl_m FROM TABLE @lt_booksuppl.

    ENDIF.


    IF update-zsy_i_booksuppl_m IS NOT INITIAL.

      lt_booksuppl = VALUE #( FOR ls_upd_bsupl IN update-zsy_i_booksuppl_m
                            ( travel_id             = ls_upd_bsupl-TravelId
                              booking_id            = ls_upd_bsupl-BookingId
                              booking_supplement_id = ls_upd_bsupl-BookingSupplementId
                              supplement_id         = ls_upd_bsupl-SupplementId
                              price                 = ls_upd_bsupl-Price
                              currency_code         = ls_upd_bsupl-CurrencyCode
                              last_changed_at       = ls_upd_bsupl-LastChangedAt ) ).

      MODIFY zsy_booksuppl_m FROM TABLE @lt_booksuppl.

    ENDIF.


    IF delete-zsy_i_booksuppl_m IS NOT INITIAL.

      lt_booksuppl = VALUE #( FOR ls_del_bsupl IN delete-zsy_i_booksuppl_m
                            ( travel_id             = ls_del_bsupl-TravelId
                              booking_id            = ls_del_bsupl-BookingId
                              booking_supplement_id = ls_del_bsupl-BookingSupplementId  ) ).

      DELETE zsy_booksuppl_m FROM TABLE @lt_booksuppl.

    ENDIF.

  ENDMETHOD.

  METHOD cleanup_finalize.

  ENDMETHOD.

ENDCLASS.
