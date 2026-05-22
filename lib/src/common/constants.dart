library pinyin_pro_flutter;

/// Probability constants for AC automaton pattern scoring.
const double kProbabilityUnknown = 1e-13;
const double kProbabilityRule = 1e-12;
const double kProbabilityDict = 2e-8;
const double kProbabilitySurname = 1.0;
const double kProbabilityCustom = 1.0;

/// Priority levels for AC automaton patterns.
const int kPriorityNormal = 1;
const int kPrioritySurname = 10;
const int kPriorityCustom = 100;
