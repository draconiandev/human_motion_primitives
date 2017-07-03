# frozen_string_literal: true

require 'fileutils'
require_relative 'constants'
require_relative 'data_modeler'
require_relative 'naive_bayes_classifier'
require_relative 'decision_tree'

# main
class Classifier
  def run
    initialize_files
    model_data
    implement_nbayes
    implement_dec_tree
    remove_csv_files
  end

  private

  def initialize_files
    puts '--- Creating folders if not present ---'
    ACTIVITIES.each do |activity|
      act = activity.downcase
      FileUtils.mkdir_p "Dataset/csv/#{act}"
      %w[training test].each do |file_type|
        File.new "Dataset/csv/#{act}/#{act}_#{file_type}.csv", 'a'
      end
    end
  end

  def model_data
    puts "\nModeling the data"
    ACTIVITIES.each do |activity|
      %w[training_data test_data].each do |file_type|
        DataModeler.new.public_send("#{file_type}_#{activity.downcase}")
      end
    end
  end

  def implement_nbayes
    puts "\n\nRunning Naive Bayes Classifier"
    NaiveBayesClassifier.new.train_and_validate
  end

  def implement_dec_tree
    puts "\n\nRunning ID3Tree Decision Tree Classifier"
    DecisionTreeClassifier.new.train_and_validate
  end

  def remove_csv_files
    puts "\n\n--- Removing csv files so as not to disturb future runs ---"
    FileUtils.rm_rf('Dataset/csv')
  end
end

Classifier.new.run
