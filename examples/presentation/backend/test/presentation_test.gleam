//// Tests for the presentation application
////
//// Basic tests to ensure the presentation structure works correctly

import gleeunit
import shared/content
import slides/slide_01
import slides/slide_02
import slides/slide_03
import slides/slide_04

pub fn main() {
  gleeunit.main()
}

// Test slide creation
pub fn slide_01_has_correct_number_test() {
  let slide = slide_01.slide()
  assert slide.number == 1
}

pub fn slide_02_has_correct_number_test() {
  let slide = slide_02.slide()
  assert slide.number == 2
}

pub fn slide_03_has_correct_number_test() {
  let slide = slide_03.slide()
  assert slide.number == 3
}

pub fn slide_04_has_correct_number_test() {
  let slide = slide_04.slide()
  assert slide.number == 4
}

// Test navigation logic
pub fn navigation_first_slide_has_no_previous_test() {
  let nav = content.navigation(1, 4)
  assert nav.current == 1
  assert nav.total == 4
  assert nav.has_previous == False
  assert nav.has_next == True
  assert nav.previous_url == "#"
  assert nav.next_url == "/slides/2"
}

pub fn navigation_middle_slide_has_both_test() {
  let nav = content.navigation(2, 4)
  assert nav.current == 2
  assert nav.total == 4
  assert nav.has_previous == True
  assert nav.has_next == True
  assert nav.previous_url == "/slides/1"
  assert nav.next_url == "/slides/3"
}

pub fn navigation_last_slide_has_no_next_test() {
  let nav = content.navigation(4, 4)
  assert nav.current == 4
  assert nav.total == 4
  assert nav.has_previous == True
  assert nav.has_next == False
  assert nav.previous_url == "/slides/3"
  assert nav.next_url == "#"
}

// Test slide content structure
pub fn slides_have_titles_test() {
  let slide1 = slide_01.slide()
  let slide2 = slide_02.slide()

  assert slide1.title != ""
  assert slide2.title != ""
}

pub fn slides_have_content_test() {
  let slide = slide_01.slide()
  let content_length = case slide.content {
    [] -> 0
    [_] -> 1
    [_, _] -> 2
    [_, _, _] -> 3
    [_, _, _, _] -> 4
    _ -> 99
  }

  assert content_length > 0
}
