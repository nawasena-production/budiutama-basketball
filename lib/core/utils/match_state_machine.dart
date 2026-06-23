const validTransitions = {
  'PRE_MATCH': ['Q1_ACTIVE'],
  'Q1_ACTIVE': ['Q1_BREAK'],
  'Q1_BREAK': ['Q2_ACTIVE'],
  'Q2_ACTIVE': ['HALFTIME'],
  'HALFTIME': ['Q3_ACTIVE'],
  'Q3_ACTIVE': ['Q3_BREAK'],
  'Q3_BREAK': ['Q4_ACTIVE'],
  'Q4_ACTIVE': ['CHECK_SCORE'],
  'CHECK_SCORE': ['OT_ACTIVE', 'POST_MATCH'],
  'OT_ACTIVE': ['POST_MATCH'],
  'POST_MATCH': <String>[],
};

bool isValidTransition(String from, String to) =>
    validTransitions[from]?.contains(to) ?? false;

bool isActiveState(String state) =>
    state == 'Q1_ACTIVE' ||
    state == 'Q2_ACTIVE' ||
    state == 'Q3_ACTIVE' ||
    state == 'Q4_ACTIVE' ||
    state == 'OT_ACTIVE';
