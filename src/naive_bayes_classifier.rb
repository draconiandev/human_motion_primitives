# frozen_string_literal: true

require 'nbayes'
require 'irb'

# nbayes
class NaiveBayesClassifier
  def train_and_validate
    train
    validate
  end

  private

  def train
    ACTIVITIES.each do |activity|
      act = activity.downcase
      CSV.read("Dataset/csv/#{act}/#{act}_training.csv").flatten
         .map(&:to_f).each { |e| nbayes.train([e], act) }
    end
  end

  def validate
    main_array = []
    ACTIVITIES.each_with_index do |activity, i|
      act_array = []
      act = activity.downcase
      tokens = CSV.read("Dataset/csv/#{act}/#{act}_test.csv")
                  .flatten.map(&:to_f)
      res = nbayes.classify(tokens)
      classify_each_token(nbayes, tokens, act_array, main_array)
      print_data(res, act, main_array, i)
    end
    puts main_array.map { |e| e.size }.reduce(:+)
  end

  def nbayes
    @nbayes ||= NBayes::Base.new(k: 1e-318)
  end

  def print_data(res, act, main_array, i)
    puts "\n--- #{act} ---"
    puts "Max Class: #{res.max_class}"
    print_accuracy(main_array, act, i)
    res.each do |k, _v|
      puts "Probability of being #{k}: #{res[k]}"
    end
    puts '------'
  end

  def classify_each_token(nbayes, tokens, act_array, main_array)
    tokens.each do |token|
      act_array << nbayes.classify([token]).max_by { |_k, v| v }[0]
    end
    main_array << act_array
  end

  def print_accuracy(main_array, act, i)
    per = (main_array[i].count(act).to_f / main_array[i].count).round(4) * 100
    puts "\nAccuracy of predicting '#{act}' : #{per}%"
  end
end
