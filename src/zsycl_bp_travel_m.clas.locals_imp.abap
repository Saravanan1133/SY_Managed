CLASS lhc_ZSY_I_TRAVEL_M DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR zsy_i_travel_m RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR zsy_i_travel_m RESULT result.
    METHODS accepttravel FOR MODIFY
       keys FOR ACTION zsy_i_travel_m~accepttravel RESULT result.

    METHODS copytravel FOR MODIFY
       keys FOR ACTION zsy_i_travel_m~copytravel.

    METHODS recalctotalprice FOR MODIFY
       keys FOR ACTION zsy_i_travel_m~recalctotalprice.

    METHODS rejecttravel FOR MODIFY
       keys FOR ACTION zsy_i_travel_m~rejecttravel RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR zsy_i_travel_m RESULT result.
    METHODS validatecustomer FOR VALIDATE ON SAVE
       keys FOR zsy_i_travel_m~validatecustomer.
    METHODS determinetotalprice FOR DETERMINE ON MODIFY
       keys FOR zsy_i_travel_m~determinetotalprice.

    METHODS earlynumbering_cba_booking FOR NUMBERING
       entities FOR CREATE zsy_i_travel_m\_booking.

    METHODS earlynumbering_create FOR NUMBERING
       entities FOR CREATE zsy_i_travel_m.

ENDCLASS.

CLASS lhc_ZSY_I_TRAVEL_M IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA(lt_entities) = entities.
    DELETE lt_entities WHERE TravelId IS NOT INITIAL.

    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
*        ignore_buffer     =
            nr_range_nr       =  '01'
            object            = '/DMO/TRV_M'
            quantity          = CONV #(  lines(  lt_entities ) )
          IMPORTING
            number            = DATA(lv_latest_num)
            returncode        = DATA(lv_retcode)
            returned_quantity = DATA(lv_qty)
        ).

      CATCH cx_nr_object_not_found.
      CATCH cx_number_ranges INTO DATA(lo_error).
    ENDTRY.

    IF lv_latest_num IS INITIAL.

      LOOP AT lt_entities INTO DATA(ls_entities).

        APPEND VALUE #( %cid  = ls_entities-%cid
                       %key   = ls_entities-%key ) TO failed-zsy_i_travel_m.

        APPEND VALUE #( %cid  = ls_entities-%cid
                       %key   = ls_entities-%key
                       %msg   = lo_error ) TO reported-zsy_i_travel_m.
      ENDLOOP.

      EXIT.

    ENDIF.


    ASSERT lv_qty = lines( lt_entities ).

    DATA(lv_curr_num) = lv_latest_num - lv_qty.

    LOOP AT lt_entities INTO ls_entities.

      lv_curr_num += 1.

      APPEND VALUE #( %cid     = ls_entities-%cid
                      TravelId = lv_curr_num ) TO mapped-zsy_i_travel_m.

    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_cba_Booking.

    DATA: lt_keys        TYPE TABLE FOR READ IMPORT zsy_i_travel_m\_Booking,
          lt_mapped      TYPE TABLE FOR MAPPED EARLY zsy_i_booking_m,
          lv_max_booking TYPE /dmo/booking_id.

    lt_keys = CORRESPONDING #( entities ).

    READ ENTITIES  OF zsy_i_travel_m IN LOCAL MODE ENTITY zsy_i_travel_m BY \_Booking
    ALL FIELDS WITH lt_keys LINK DATA(lt_book_result).

*--------------------------------------------------------------------*
* Process each unique TravelId
*--------------------------------------------------------------------*

    LOOP AT entities
         ASSIGNING FIELD-SYMBOL(<ls_group>)
         GROUP BY <ls_group>-TravelId.

      CLEAR lv_max_booking.

*--------------------------------------------------------------------*
* 1. Find maximum BookingId already existing for this Travel (SAVED IN DB/TRANS.BUFFER)
*--------------------------------------------------------------------*

      LOOP AT lt_book_result INTO DATA(ls_result) USING KEY entity WHERE source-TravelId = <ls_group>-TravelId.

        IF lv_max_booking < ls_result-target-BookingId.
          lv_max_booking = ls_result-target-BookingId.
        ENDIF.

      ENDLOOP.

*--------------------------------------------------------------------*
* 2. Find maximum BookingId already supplied in incoming entities
*--------------------------------------------------------------------*

      LOOP AT GROUP <ls_group>
           ASSIGNING FIELD-SYMBOL(<ls_entity>).

        LOOP AT <ls_entity>-%target
             ASSIGNING FIELD-SYMBOL(<ls_target>)
             WHERE BookingId IS NOT INITIAL.

          IF <ls_target>-BookingId > lv_max_booking.
            lv_max_booking = <ls_target>-BookingId.
          ENDIF.

        ENDLOOP.

      ENDLOOP.

*--------------------------------------------------------------------*
* 3. Generate BookingIds for targets without a BookingId
*--------------------------------------------------------------------*

      LOOP AT <ls_group>-%target INTO DATA(ls_target_bookings).

        APPEND CORRESPONDING #( ls_target_bookings ) TO lt_mapped ASSIGNING FIELD-SYMBOL(<fs_mapped>).

        IF ls_target_bookings-BookingId IS INITIAL.
          lv_max_booking += 10.
          <fs_mapped>-BookingId = lv_max_booking.
        ENDIF.

      ENDLOOP.

    ENDLOOP.

    mapped-zsy_i_booking_m = lt_mapped.

  ENDMETHOD.

  METHOD copyTravel.

**// Local data declaration
    DATA: lt_trvl_key     TYPE TABLE FOR READ IMPORT zsy_i_travel_m,
          lt_book_key     TYPE TABLE FOR READ IMPORT zsy_i_travel_m\_Booking,
          lt_booksupl_key TYPE TABLE FOR READ IMPORT zsy_i_BOOKING_m\_BookingSuppl,


          lt_trvl_crt     TYPE TABLE FOR CREATE zsy_i_travel_m,
          lt_book_crt     TYPE TABLE FOR CREATE zsy_i_travel_m\_Booking,
          lt_booksupl_crt TYPE TABLE FOR CREATE zsy_i_booking_m\_BookingSuppl.



    READ TABLE keys INTO DATA(ls_keys) INDEX 1.

    lt_trvl_key = CORRESPONDING #( keys ).
    lt_book_key = CORRESPONDING #( keys ).

    IF sy-subrc = 0.

      "First Read Travel Entity and Booking Entity
      "They can be read together since both are associated, hence both data can be read
      "with the help of Travel Id Alone

      "Note : we can't read the booking supplement entity, since travel and booking supplement is not associated
      "also we need the booking key id to get the supplement details

      READ ENTITIES OF zsy_i_travel_m IN LOCAL MODE

      ENTITY zsy_i_travel_m ALL FIELDS WITH lt_trvl_key
      RESULT DATA(lt_trvl_r)

      BY \_Booking ALL FIELDS WITH lt_book_key RESULT DATA(lt_book_r).

      "Once we have got the Booking results, based on the booking results we read its associated
      "booking supplement

      lt_booksupl_key = CORRESPONDING #( lt_book_r ).

      READ ENTITIES OF zsy_i_travel_m IN LOCAL MODE
      ENTITY zsy_i_booking_m BY \_BookingSuppl ALL FIELDS WITH lt_booksupl_key
      RESULT DATA(lt_booksupl_r).

      LOOP AT lt_trvl_R INTO DATA(ls_trvl_r).

        APPEND CORRESPONDING #( ls_trvl_r EXCEPT travelid ) TO lt_trvl_crt ASSIGNING FIELD-SYMBOL(<fs_trvl_crt>).

        <Fs_trvl_crt>-%cid      = ls_keys-%cid.
        <Fs_trvl_crt>-BeginDate = '20260831'.
        <Fs_trvl_crt>-EndDate   = '20260930'.
        <FS_TRVL_cRT>-Status    = 'N'.

        <fs_trvl_crt>-%control  = VALUE #( AgencyId     = if_abap_behv=>mk-on
                                           BeginDate    = if_abap_behv=>mk-on
                                           BookingFee   = if_abap_behv=>mk-on
                                           Createdat    = if_abap_behv=>mk-on
                                           Createdby    = if_abap_behv=>mk-on
                                           CurrencyCode = if_abap_behv=>mk-on
                                           CustomerId   = if_abap_behv=>mk-on
                                           Description  = if_abap_behv=>mk-on
                                           EndDate      = if_abap_behv=>mk-on
                                           Status       = if_abap_behv=>mk-on
                                           TotalPrice   = if_abap_behv=>mk-on
                                           ).


        APPEND VALUE #( %cid_ref = <Fs_trvl_crt>-%cid ) TO lt_book_crt ASSIGNING FIELD-SYMBOL(<fS_book_crt>).

        LOOP AT lt_book_R INTO DATA(ls_book_r).

          APPEND CORRESPONDING #( ls_book_r EXCEPT travelid ) TO <fs_book_crt>-%target ASSIGNING FIELD-SYMBOL(<fs_book_target>).

          <fs_book_target>-%cid = <Fs_trvl_crt>-%cid && ls_book_r-BookingId.

          <fs_book_target>-%control = VALUE #( BookingDate   = if_abap_behv=>mk-on
                                               BookingId     = if_abap_behv=>mk-on
                                               BookingStatus = if_abap_behv=>mk-on
                                               CarrierId     = if_abap_behv=>mk-on
                                               ConnectionId  = if_abap_behv=>mk-on
                                               CurrencyCode  = if_abap_behv=>mk-on
                                               CustomerId    = if_abap_behv=>mk-on
                                               FlightDate    = if_abap_behv=>mk-on
                                               FlightPrice   = if_abap_behv=>mk-on
                                             ).

          APPEND VALUE #( %cid_ref = <fs_book_target>-%cid ) TO lt_booksupl_crt ASSIGNING FIELD-SYMBOL(<fs_booksupl_crt>).


          LOOP AT lt_booksupl_r INTO DATA(ls_booksupl_r) USING KEY entity WHERE TravelId  = ls_trvl_r-TravelId
                                                                          AND   BookingId = ls_book_r-BookingId.

            APPEND CORRESPONDING #( ls_booksupl_r EXCEPT travelid ) TO <Fs_booksupl_crt>-%target ASSIGNING FIELD-SYMBOL(<fs_booksupl_target>).

            <fs_booksupl_target>-%cid = <Fs_trvl_crt>-%cid && ls_book_r-BookingId && ls_booksupl_R-BookingSupplementId.

            <fs_booksupl_target>-%control = VALUE #( BookingId           = if_abap_behv=>mk-on
                                                     BookingSupplementId = if_abap_behv=>mk-on
                                                     CurrencyCode        = if_abap_behv=>mk-on
                                                     Price               = if_abap_behv=>mk-on
                                                     SupplementId        = if_abap_behv=>mk-on    ).

          ENDLOOP.

        ENDLOOP.

      ENDLOOP.


      MODIFY ENTITIES OF zsy_i_travel_m IN LOCAL MODE
      ENTITY zsy_i_travel_m CREATE FROM lt_trvl_crt

      ENTITY zsy_i_travel_m CREATE BY \_Booking FROM lt_book_crt

      ENTITY zsy_i_booking_m CREATE BY \_BookingSuppl FROM lt_booksupl_crt

      MAPPED DATA(lt_mapped) FAILED DATA(lt_failed) REPORTED DATA(lt_reported).

      IF lt_failed IS INITIAL.
        mapped = CORRESPONDING #( lt_mapped ).
      ELSE.
        failed = CORRESPONDING #( lt_failed ).
        reported = CORRESPONDING #( lt_reported ).
      ENDIF.



    ENDIF.

  ENDMETHOD.

  METHOD acceptTravel.

    DATA: lt_trvl_upd  TYPE TABLE FOR UPDATE zsy_i_travel_m,
          lt_trvl_read TYPE TABLE FOR READ IMPORT zsy_i_travel_m,
          lt_mapped    TYPE RESPONSE FOR MAPPED EARLY zsy_i_travel_m.

    lt_trvl_upd = VALUE #( FOR ls_keys IN keys ( %key            = ls_keys-%key
                                                 %data-Status    = 'B'
                                                 %control-Status = if_abap_behv=>mk-on ) ).


    MODIFY ENTITIES OF zsy_i_travel_m IN LOCAL MODE
    ENTITY zsy_i_travel_m UPDATE FROM lt_trvl_upd
    REPORTED DATA(lt_reported) FAILED DATA(lt_failed) MAPPED DATA(lt_mapped1).

    IF lt_failed IS INITIAL.

      lt_trvl_read = VALUE #( FOR ls_keys IN keys ( %key  = ls_keys-%key
                                                    %control = VALUE #( AgencyId     = if_abap_behv=>mk-on
                                                                        BeginDate    = if_abap_behv=>mk-on
                                                                        BookingFee   = if_abap_behv=>mk-on
                                                                        Createdat    = if_abap_behv=>mk-on
                                                                        Createdby    = if_abap_behv=>mk-on
                                                                        CurrencyCode = if_abap_behv=>mk-on
                                                                        CustomerId   = if_abap_behv=>mk-on
                                                                        Description  = if_abap_behv=>mk-on
                                                                        EndDate      = if_abap_behv=>mk-on
                                                                        Status       = if_abap_behv=>mk-on
                                                                        TotalPrice   = if_abap_behv=>mk-on )  ) ).

      READ ENTITIES OF zsy_i_travel_m IN LOCAL MODE
      ENTITY zsy_i_travel_m FROM lt_trvl_read
      RESULT DATA(lt_trvl_result) REPORTED DATA(lt_error_read) FAILED DATA(lt_fail_read).

      IF lt_fail_read IS INITIAL.

        result = VALUE #( FOR wa IN lt_trvl_result
                        ( %key   = wa-%key
                          %param = CORRESPONDING #( wa ) ) ).

        mapped = CORRESPONDING #( lt_mapped ).

      ELSE.
        reported = CORRESPONDING #( lt_error_read ).
      ENDIF.


    ELSE.
      reported = CORRESPONDING #( lt_reported ).
    ENDIF.

  ENDMETHOD.

  METHOD rejectTravel.

    DATA: lt_trvl_upd  TYPE TABLE FOR UPDATE zsy_i_travel_m,
          lt_trvl_read TYPE TABLE FOR READ IMPORT zsy_i_travel_m,
          lt_mapped    TYPE RESPONSE FOR MAPPED EARLY zsy_i_travel_m.

    lt_trvl_upd = VALUE #( FOR ls_keys IN keys ( %key            = ls_keys-%key
                                                 %data-Status    = 'X'
                                                 %control-Status = if_abap_behv=>mk-on ) ).


    MODIFY ENTITIES OF zsy_i_travel_m IN LOCAL MODE
    ENTITY zsy_i_travel_m UPDATE FROM lt_trvl_upd
    REPORTED DATA(lt_reported) FAILED DATA(lt_failed) MAPPED DATA(lt_mapped1).

    IF lt_failed IS INITIAL.

      lt_trvl_read = VALUE #( FOR ls_keys IN keys ( %key  = ls_keys-%key
                                                    %control = VALUE #( AgencyId     = if_abap_behv=>mk-on
                                                                        BeginDate    = if_abap_behv=>mk-on
                                                                        BookingFee   = if_abap_behv=>mk-on
                                                                        Createdat    = if_abap_behv=>mk-on
                                                                        Createdby    = if_abap_behv=>mk-on
                                                                        CurrencyCode = if_abap_behv=>mk-on
                                                                        CustomerId   = if_abap_behv=>mk-on
                                                                        Description  = if_abap_behv=>mk-on
                                                                        EndDate      = if_abap_behv=>mk-on
                                                                        Status       = if_abap_behv=>mk-on
                                                                        TotalPrice   = if_abap_behv=>mk-on )  ) ).

      READ ENTITIES OF zsy_i_travel_m IN LOCAL MODE
      ENTITY zsy_i_travel_m FROM lt_trvl_read
      RESULT DATA(lt_trvl_result) REPORTED DATA(lt_error_read) FAILED DATA(lt_fail_read).

      IF lt_fail_read IS INITIAL.

        result = VALUE #( FOR wa IN lt_trvl_result
                        ( %key   = wa-%key
                          %param = CORRESPONDING #( wa ) ) ).

        mapped = CORRESPONDING #( lt_mapped ).

      ELSE.
        reported = CORRESPONDING #( lt_error_read ).
      ENDIF.


    ELSE.
      reported = CORRESPONDING #( lt_reported ).
    ENDIF.


  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zsy_i_travel_m IN LOCAL MODE
    ENTITY zsy_i_travel_m FIELDS ( TravelId Status )
    WITH CORRESPONDING #( keys ) RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result
                    ( %tky = ls_result-%tky
                      %features-%action-acceptTravel = COND #( WHEN ls_Result-Status = 'B' THEN if_Abap_behv=>fc-o-disabled
                                                               ELSE  if_Abap_behv=>fc-o-enabled )
                      %features-%action-rejectTravel = COND #( WHEN ls_result-Status = 'X' THEN if_Abap_behv=>fc-o-disabled
                                                               ELSE if_Abap_behv=>fc-o-enabled )
                      %features-%assoc-_Booking      = COND #( WHEN ls_result-Status = 'X' THEN if_Abap_behv=>fc-o-disabled
                                                               ELSE if_Abap_behv=>fc-o-enabled )

                                                                ) ).

  ENDMETHOD.



  METHOD validateCustomer.

    DATA: lt_customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    READ ENTITY IN LOCAL MODE zsy_i_travel_m FIELDS ( TravelId CustomerId )
    WITH CORRESPONDING #( keys ) RESULT DATA(lt_trvl_r).

    lt_customer = CORRESPONDING #( lt_trvl_r DISCARDING DUPLICATES MAPPING customer_id = CustomerId ).

    DELETE lt_customer WHERE customer_id IS INITIAL.

    IF lt_customer IS NOT INITIAL.

      SELECT FROM /dmo/customer FIELDS customer_id
             FOR ALL ENTRIES IN @lt_customer
             WHERE customer_id = @lt_customer-customer_id
             INTO TABLE @DATA(lt_cust_db).

    ENDIF.

    LOOP AT lt_trvl_r INTO DATA(ls_trvl).

      IF ls_trvl IS INITIAL OR NOT line_ExistS( lt_cust_db[ customer_id = ls_trvl-CustomerId ] ).

        APPEND VALUE #( %tky = ls_Trvl-%tky ) TO failed-zsy_i_travel_m.

        APPEND VALUE #( %tky = ls_trvl-%tky
                    %msg = NEW /dmo/cm_flight_messages(
                                        textid                = /dmo/cm_flight_messages=>customer_unkown
                                       customer_id           = ls_trvl-CustomerId
                            severity              = if_abap_behv_message=>severity-error
                            )
                    %element-CustomerId = if_abap_behv=>mk-on

    )
               TO reported-zsy_i_travel_m.


      ENDIF.


    ENDLOOP.



  ENDMETHOD.

  METHOD determineTotalPrice.

    MODIFY ENTITY IN LOCAL MODE zsy_i_travel_m EXECUTE recalcTotalPrice
    FROM CORRESPONDING #(  keys ) FAILED DATA(LT_failed) REPORTED DATA(lt_reported).

  ENDMETHOD.

  METHOD recalcTotalPrice.

    READ ENTITIES OF zsy_i_travel_m IN LOCAL MODE
    ENTITY zsy_i_travel_m FIELDS ( TravelId BookingFee CurrencyCode )
    WITH CORRESPONDING #( keys ) RESULT DATA(lt_travel)

    ENTITY ZSY_I_TRAVEL_m BY \_Booking FIELDS ( TravelId BookingId FlightPrice CurrencyCode )
    WITH CORRESPONDING #( keys ) RESULT DATA(lt_book).


    READ ENTITIES OF zsy_i_travel_m IN LOCAL MODE
    ENTITY zsy_i_booking_m BY \_BookingSuppl
    FIELDS ( TravelId BookingId PricE CurrencyCode )
    WITH CORRESPONDING #(  lt_book ) RESULT DATA(lt_booksuppl).


    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<fs_travel>).

      DATA(lv_tot_fprice) = REDUCE /dmo/flight_price(  INIT fprice TYPE /dmo/flight_price FOR ls_book IN lt_book
                                                       WHERE  (  TravelId = <Fs_travel>-TravelId )
                                                       NEXT fprice += ls_book-FlightPrice ).

      DATA(lv_tot_Pprice) = REDUCE /dmo/supplement_price(  INIT pprice TYPE /dmo/supplement_price FOR ls_booksupl IN lt_booksuppl
                                                   WHERE  ( TravelId = <Fs_travel>-TravelId )
                                                   NEXT pprice += ls_booksupl-Price ).

      <fs_travel>-TotalPrice = <Fs_travel>-BookingFee + lv_tot_fprice + lv_tot_pprice.

    ENDLOOP.

    MODIFY ENTITY IN LOCAL MODE zsy_i_travel_m UPDATE FIELDS ( TotalPrice )
    WITH CORRESPONDING #( lt_travel ) FAILED DATA(lt_failed1).



  ENDMETHOD.


ENDCLASS.























