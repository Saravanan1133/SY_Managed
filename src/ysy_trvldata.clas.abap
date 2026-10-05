CLASS ysy_trvldata DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES:
      if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ysy_trvldata IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

**// Local data declaration
*DATA: lt_sy_travel TYPE ZSY_TRAVEL_UM,

    " delete existing entries in the database table
    DELETE FROM zsy_travel_m.
    DELETE FROM zsy_booking_m.
    DELETE FROM zsy_booksuppl_m.
    COMMIT WORK.

*        SELECT *
*          FROM /dmo/travel_m INTO TABLE @DATA(lt_dmo_travel).

    " insert travel demo data
*    INSERT zsy_travel_m FROM TABLE @lt_dmo_travel.
    INSERT zsy_travel_m FROM ( SELECT * FROM /dmo/travel_m ).

    COMMIT WORK.

    " insert booking demo data
    INSERT zsy_booking_m FROM (
        SELECT *
          FROM   /dmo/booking_m
*            JOIN ytravel_tech_m AS y
*            ON   booking~travel_id = y~travel_id

      ).
    COMMIT WORK.
    INSERT zsy_booksuppl_m FROM (
        SELECT *
          FROM   /dmo/booksuppl_m
*            JOIN ytravel_tech_m AS y
*            ON   booking~travel_id = y~travel_id

      ).
    COMMIT WORK.

*    DELETE FROM zsy_cc_tbl_d WHERE validto IS INITIAL.

    out->write( 'Travel and booking demo data inserted.' ).


  ENDMETHOD.
ENDCLASS.



