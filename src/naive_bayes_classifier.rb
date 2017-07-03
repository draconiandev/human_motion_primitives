# frozen_string_literal: true

require 'nbayes'

# main
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
    ACTIVITIES.each do |activity|
      act = activity.downcase
      tokens = CSV.read("Dataset/csv/#{act}/#{act}_test.csv")
                  .flatten.map(&:to_f)
      res = nbayes.classify(tokens)
      print_data(res, act)
    end
  end

  def nbayes
    @nbayes ||= NBayes::Base.new
  end

  def print_data(res, act)
    puts "\n--- #{act} ---"
    puts "Max Class: #{res.max_class}"
    res.each do |k, _v|
      puts "Probability of being #{k}: #{res[k]}"
    end
    puts '------'
  end
end
