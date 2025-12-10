use std::collections::bounded_vec::BoundedVec;

use crate::{
    TEXT_CHAR_TABLE,
    headers::constrain_header_field,
    Sequence,
    MAX_TEXT_LENGTH,
};


/**
 * Get the subject from an email header
 *
 * @param MAX_HEADER_LENGTH - The maximum length of the email header
 * @param MAX_SUBJECT_LENGTH - The maximum length of the subject field
 * @param header - The email header as validated in the DKIM signature
 * @param header_field_sequence - The sequence of the header field
 * @param subject_sequence - The sequence of the subject content
 */
pub fn get_subject_header_value<
    let MAX_HEADER_LENGTH: u32,
    let HEADER_FIELD_NAME_LENGTH: u32,
>(
    header: BoundedVec<u8, MAX_HEADER_LENGTH>,
    header_field_sequence: Sequence,
    text_sequence: Sequence,
    header_field_name: [u8; HEADER_FIELD_NAME_LENGTH],
) -> BoundedVec<u8, MAX_TEXT_LENGTH> {

    constrain_header_field::<MAX_HEADER_LENGTH, MAX_TEXT_LENGTH + HEADER_FIELD_NAME_LENGTH + 1,HEADER_FIELD_NAME_LENGTH>(
        header, header_field_sequence, header_field_name);


    assert(
        text_sequence.index >= header_field_sequence.index
            & text_sequence.end_index() <= header_field_sequence.end_index(),
        "Header text sequence out of bounds",
    );

    parse_subject(header, text_sequence)
}


/**
 * Parse and extract the subject content from the header
 *
 * @param MAX_HEADER_LENGTH - The maximum length of the email header
 * @param MAX_TEXT_LENGTH - The maximum length of the subject
 * @param header - The email header
 * @param subject_sequence - The sequence pointing to the subject content
 */
pub fn parse_subject<let MAX_HEADER_LENGTH: u32>(
    header: BoundedVec<u8, MAX_HEADER_LENGTH>,
    text_sequence: Sequence,
) -> BoundedVec<u8, MAX_TEXT_LENGTH> {
    
    // check the email address and assign
    let mut text: BoundedVec<u8, MAX_TEXT_LENGTH> = BoundedVec::new();
    for i in 0..MAX_TEXT_LENGTH {
        let index = text_sequence.index + i;
        if index < text_sequence.end_index() {
            let letter = header.get_unchecked(index);

            assert(
                TEXT_CHAR_TABLE[letter as u32] == 1,
                "Header text must only contain acceptable characters",
            );

            text.push(letter);
        }
    }
    text
}