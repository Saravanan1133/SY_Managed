CLASS zsycl_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zsycl_eml IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

**// Local data declaration
*    DATA: lt_keys   TYPE TABLE FOR READ IMPORT zsy_i_travel_m,
*          ls_result TYPE TABLE FOR READ RESULT zsy_i_travel_m,
*          ls_failed TYPE RESPONSE FOR FAILED zsy_i_travel_m.
*
*    lt_keys = VALUE #( ( %key-TravelId = '00004152'
*                        %control-AgencyId   = if_abap_behv=>mk-on
*                        %control-CustomerId = if_abap_behv=>mk-on
*                        %control-BeginDate  = if_abap_behv=>mk-on   ) ).

*    READ ENTITY zsy_i_travel_m FROM lt_keys
*    RESULT ls_result FAILED ls_failed.
*
*    IF ls_failed-zsy_i_travel_m IS NOT INITIAL.
*
*      out->write( '' ).
*
*    ELSE.
*
*      out->write( ls_result ).
*
*    ENDIF.
*
*
*    READ ENTITY zsy_i_travel_m FIELDS (  AgencyId CustomerId BeginDate )
*    WITH VALUE #( (  %key-TravelId = '00004152' ) )
*    RESULT ls_result FAILED ls_failed.
*
*    READ ENTITY zsy_i_travel_m ALL FIELDS
*    WITH VALUE #( (  %key-TravelId = '00004152' )
*                  (  %key-TravelId = '00004153' ) )
*    RESULT ls_result FAILED ls_failed.

*    DATA: ls_book_result TYPE TABLE FOR READ RESULT zsy_i_booking_m.
*
*
*    READ ENTITY zsy_i_travel_m BY \_Booking ALL FIELDS
*    WITH VALUE #( (  %key-TravelId = '00004152' )
*                  (  %key-TravelId = '00004150' ) )
*    RESULT ls_book_result FAILED ls_failed.
*
*    IF ls_failed-zsy_i_travel_m IS NOT INITIAL.
*
*      out->write( '' ).
*
*    ELSE.
*
*      out->write( ls_book_result ).
*
*    ENDIF.

*    DATA: lt_book_keys TYPE TABLE FOR READ IMPORT zsy_i_booking_m.
*
*    lt_book_keys = VALUE #(  (  %key-TravelId  = '00004150'
*                                %key-BookingId = '0010' ) ).
*
*
*    READ ENTITIES OF zsy_i_travel_m
*
*    ENTITY zsy_i_travel_m
*    ALL FIELDS WITH lt_keys RESULT  ls_result
*
*    ENTITY zsy_i_booking_m
*    ALL FIELDS WITH lt_book_keys RESULT ls_book_result
*
*    FAILED ls_failed.

*    DATA: lt_optab       TYPE abp_behv_retrievals_tab,
*          ls_opfail      TYPE abp_behv_response_tab,
*          lt_book_keys   TYPE TABLE FOR READ IMPORT zsy_i_travel_m\_Booking,
*          lt_book_result TYPE TABLE FOR READ RESULT zsy_i_travel_m\_Booking.


*    lt_optab = VALUE #( ( op = if_abap_behv=>op-r-read
*                          entity_name = 'ZSY_I_TRAVEL_M'
*                          instances = REF #( lt_keys )
*                          results   = REF #( ls_result )
*                            ) ).
*
*    READ ENTITIES OPERATIONS lt_optab FAILED ls_opfail.

*    lt_book_keys = VALUE #( ( %key-TravelId = '00004150'
*                              %control = VALUE #( BookingDate = if_abap_behv=>mk-on
*                                                  BookingStatus = if_abap_behv=>mk-on
*                                                  BookingId = if_abap_behv=>mk-on )
*                          ) ).
*
*    lt_optab = VALUE #( (  op = if_abap_behv=>op-r-read_ba
*                           entity_name = 'ZSY_I_TRAVEL_M'
*                           sub_name = '_BOOKING'
*                           instances = REF #( lt_book_keys )
*                           results = REF #( lt_book_result )
*
*                            ) ).
*
*    READ ENTITIES OPERATIONS lt_optab FAILED ls_opfail.

*
*    IF ls_failed-zsy_i_travel_m IS NOT INITIAL.
*
*      out->write( '' ).
*
*    ELSE.
*
*      out->write( ls_result ).
*      out->write( lt_book_result ).
*
*    ENDIF.
**********************************************************************

    DATA: lt_trvl_create TYPE TABLE FOR CREATE zsy_i_travel_m,
          lt_book_create TYPE TABLE FOR CREATE zsy_i_travel_m\_Booking.

**--------------------------------------------------------**
*            ROOT & CHILD ENTITY CREATION TOGETHER
**--------------------------------------------------------**

    lt_trvl_create = VALUE #( ( %cid = 'CID1'
                                %data-BeginDate = '20260829'
                                %control-BeginDate = if_abap_behv=>mk-on ) ).
*
*    lt_book_create = VALUE #( ( %cid_ref = 'CID1'
*                                %target  = VALUE #( (  %cid = 'CID11'
*                                                       %data-BookingDate     = '20260829'
*                                                       %control-BookingDate  = if_Abap_behv=>mk-on ) )  ) ).
*
*    MODIFY ENTITY zsy_i_travel_m CREATE FROM lt_trvl_create CREATE BY \_Booking FROM lt_book_create
*    FAILED FINAL(lt_failed)
*    MAPPED FINAL(lt_mapped) REPORTED FINAL(lt_reported).
*
*    IF lt_failed-zsy_i_travel_m IS INITIAL.
*
*      COMMIT ENTITIES.
*
*    ENDIF.

**--------------------------------------------------------**
*            ROOT ENTITY DELETION
**--------------------------------------------------------**

*    DATA: lt_trvl_delete TYPE TABLE FOR DELETE zsy_i_travel_m.
*
*    lt_trvl_delete = VALUE #( ( %key-TravelId = '00004152' ) ).
*
*
*    MODIFY ENTITY zsy_i_travel_m DELETE FROM lt_trvl_delete
*    FAILED FINAL(lt_failed1)
*    MAPPED FINAL(lt_mapped1)
*    REPORTED FINAL(lt_reported1).
*
*    IF lt_failed1-zsy_i_travel_m IS INITIAL.
*      COMMIT ENTITIES.
*    ENDIF.

*NOTE: Once the root entity is deleted, its dependent child entities
*also gets deleted, since they are tightly associated

**--------------------------------------------------------**
*             CHILD ENTITY DELETION
**--------------------------------------------------------**

*    DATA: lt_book_delete TYPE TABLE FOR DELETE zsy_i_booking_m.
*
*    lt_book_delete = VALUE #( ( %key-TravelId = '00004152'
*                                %key-BookingId = '10' ) ).
*
*    MODIFY ENTITY zsy_i_booking_m DELETE FROM lt_book_delete
*    FAILED FINAL(lt_failed2)
*    MAPPED FINAL(lt_mapped2)
*    REPORTED FINAL(lt_reported2).
*
*    IF lt_failed2-zsy_i_travel_m IS INITIAL.
*      COMMIT ENTITIES.
*    ENDIF.

**--------------------------------------------------------**
*              AUTO FILL CID FOR ROOT ENTY. CREATION
**--------------------------------------------------------**

*    MODIFY ENTITY zsy_i_travel_m CREATE AUTO FILL CID WITH lt_trvl_create
*        FAILED FINAL(lt_failed3)
*        MAPPED FINAL(lt_mapped3)
*        REPORTED FINAL(lt_reported3).
*
** NOTE: If you are creating using AUTO FILL CID, we cannot create the corresponding child entity
** together under the root entity
*
*    IF lt_failed3-zsy_i_travel_m IS INITIAL.
*      COMMIT ENTITIES.
*    ENDIF.

**--------------------------------------------------------**
*             UPDATE
**--------------------------------------------------------**

*    DATA: lt_trvl_upd TYPE TABLE FOR UPDATE zsy_i_travel_m.
*
*    lt_trvl_upd = VALUE #( ( %key-TravelId = '00004135'
*                             %data-BeginDate = '20240301'
*                             %control-BeginDate = if_abap_behv=>mk-on ) ).
*
*    MODIFY ENTITIES OF zsy_i_travel_m
*    ENTITY zsy_i_travel_m UPDATE FROM lt_trvl_upd
*    FAILED DATA(lt_failed4) MAPPED DATA(lt_mapped4)
*    REPORTED DATA(lt_reported4).
*
*    IF lt_failed4-zsy_i_travel_m IS INITIAL.
*      COMMIT ENTITIES.
*    ENDIF.

*           (((( OR ))))

*  MODIFY ENTITIES OF zsy_i_travel_m
*  ENTITY zsy_i_travel_m UPDATE FIELDS ( BeginDate )
*  WITH VALUE #( ( %key-TravelId = '00004135'
*                  %data-BeginDate = '20240301' ) )
*  FAILED DATA(lt_failed4) MAPPED DATA(lt_mapped4)
*  REPORTED DATA(lt_reported4).

*           (((( OR ))))


* The below will create performance issue.
* Only advantage in the below is, we wont be specifying the control structure i.e.) fields to be updated
*  MODIFY ENTITIES OF zsy_i_travel_m
*  ENTITY zsy_i_travel_m UPDATE SET FIELDS
*  WITH VALUE #( ( %key-TravelId = '00004135'
*                  %data-BeginDate = '20240301' ) )
*  FAILED DATA(lt_failed4) MAPPED DATA(lt_mapped4)
*  REPORTED DATA(lt_reported4).

**--------------------------------------------------------**
*             UPDATE + DELETE
**--------------------------------------------------------**

    DATA: lt_trvl_upd1 TYPE TABLE FOR UPDATE zsy_i_travel_m,
          lt_trvl_del1 TYPE TABLE FOR DELETE zsy_i_travel_m.

    MODIFY ENTITIES OF zsy_i_travel_m
    ENTITY zsy_i_travel_m UPDATE FROM lt_trvl_upd1

    ENTITY zsy_i_travel_m DELETE FROM lt_trvl_del1

    ENTITY zsy_i_booking_m DELETE FROM VALUE #( ( %key-travelid = ''  "some other travel id apart from the one used in LT_TRVL_UPD1
                                                  %key-bookingid = '' ) )
    FAILED DATA(lt_failed5) MAPPED DATA(lt_mapped5) REPORTED DATA(lt_reported5).

    IF lt_reported5-zsy_i_travel_m IS INITIAL.
      COMMIT ENTITIES.
    ENDIF.



  ENDMETHOD.
ENDCLASS.
