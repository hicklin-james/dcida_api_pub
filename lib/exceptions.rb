module Exceptions
  class NotAuthenticatedError < StandardError; end

  class MissingParams < StandardError; end

  class InvalidParams < StandardError; end

  class DceImportError < StandardError
   
    UNKNOWN_ERROR = "An unknown error occured"
    MISSING_OPTION_ID_ROW = "Couldn't find a row with all the option IDs in csv file."
    UNEQUAL_ANSWERS_PER_SET = "Unequal number of answers per question set."
    PROPERTY_LEVEL_OUT_OF_RANGE = "A question set's property level is less than 1 or greater than the total number of property levels."
    MAX_PROPERTY_LEVEL_INCORRECT = "The maximum value for a property level is not equal to the property's actual number of property levels."
    INVALID_PROPERTY_ID = "Property ID is an invalid ID. No record found."
    PROPERTY_TITLE_ID_BAD_MATCH = "Property ID does not match property title for the column."
    DESIGN_HEADERS_MISSING = "'question_set' and/or 'answer' missing from csv file."
    PROP_TITLE_MISSING = "Property title is missing from csv file"


    def self.missing_option_label(row_index)
      "Row #{row_index}, where row 1 is the first row after your header rows, has no options selected. There must be at least one selected option per row."
    end

    def self.missing_label(l)
      "Couldn't find '#{l}' in csv file."
    end
  end

  class DceExportError < StandardError

    GENERIC_HEADER_LENGTH_ZERO = "The length of the generic headers must be greater than zero"
    NO_OPTIONS = "There must be at least one option defined to create a DCE"
    NUM_QUESTIONS_ZERO = "There must be between 1 and 10 question in your DCE"
    NUM_RESPONSES_LESS_THAN_TWO = "There must be between 2 and 3 responses per question"
    NO_PROPERTIES = "There must be at least 1 property defined to create a DCE"


    def self.props_missing_levels(props)
      "Properties: \n#{props.join(",\n")}\n need at least one property level."
    end
  end

  class BwImportError < StandardError

    NO_ATTRIBUTES_PER_QUESTION_HEADER = "CSV file must have an 'Attributes per question' column header"
    NO_LEVEL_ID_LABEL = "No 'Level ID' label found in CSV file"
    
    def self.wrong_number_attributes(row_index, attributes_per_question)
      "Row #{row_index}, where row 1 is the first row after your header rows, has an incorrect number of attributes selected. There should be #{attributes_per_question} attributes selected per row."
    end
  end

  class BwExportError < StandardError
    NO_OPTIONS = "There must be at least one option defined to create a Best-Worst activity"
    NO_PROPERTIES = "There must be at least 1 property defined to create a Best-Worst activity"
    NUM_QUESTIONS_ZERO = "There must be at least 1 question in your Best-Worst activity"
    NUM_ATTRIBUTES_ZERO = "There must be at least 1 attribute shown per question"

    def self.props_missing_levels(props)
      "Properties: \n#{props.join(",\n")}\n need at least one property level."
    end
  end

  class RedcapRequestFailed < StandardError; end
  
end
