# frozen_string_literal: true

require 'decisiontree'

# decision tree
class DecisionTreeClassifier
  def train_and_validate
    dec_tree.train
    validate
  end

  private

  def train
    train_array = []
    ACTIVITIES.each do |activity|
      act = activity.downcase
      train_array += CSV.read("Dataset/csv/#{act}/#{act}_training.csv")
                        .flatten.map(&:to_f).map { |e| [e, act] }
    end
    train_array
  end

  def validate
    test_set = []
    ACTIVITIES.each do |activity|
      act = activity.downcase
      CSV.read("Dataset/csv/#{act}/#{act}_test.csv").flatten.map(&:to_f)
         .map { |e| test_set << dec_tree.predict([e, act]) }
      puts "\n--- #{act} ---"
      print_data(test_set, act)
      puts '------'
    end
  end

  # Takes attribute/label => ['Vector Sum']
  # training data => @train
  # default value => 1 (can be any of the activity names as well)
  # type of dataset => takes :discrete or :continuous
  # I have assumed the dataset to be discrete
  def dec_tree
    @dt ||= DecisionTree::ID3Tree.new(['Vector Sum'], train, 1, :discrete)
  end

  def probability_ratio(test_set, act)
    hash = {}
    ACTIVITIES.each do |activity|
      act = activity.downcase
      hash[act] = test_set.count(act) / test_set.count.to_f
    end
    hash
  end

  def print_data(test_set, act)
    hash = probability_ratio(test_set, act)
    puts "Max Class: #{hash.key(hash.values.max)}"
    puts "\nAccuracy of predicting '#{act}' : #{accuracy_per(test_set, act)}%\n"
    hash.each do |k, _v|
      puts "Probability of being #{k}: #{hash[k]}"
    end
  end

  def accuracy_per(test_set, act)
    (test_set.count(act).to_f / test_set.count).round(4) * 100
  end
end
