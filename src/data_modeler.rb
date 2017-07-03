# frozen_string_literal: true

require 'csv'

# Normalize x, y and z axis accelerations into a sum of vector magnitude
# Append the data into a csv file
class DataModeler
  ACTIVITIES.each do |activity|
    %w[training test].each do |file_type|
      act = activity.downcase
      fmt_activity = "#{file_type}_data_#{act}"

      define_method fmt_activity do
        puts "--- Creating #{file_type} data for #{activity} ---"
        csv_path = "Dataset/csv/#{act}/#{act}_#{file_type}.csv"
        CSV.open(csv_path, 'a+') do |csv|
          file = "#{file_type}_file_#{act}"
          fetch_data_and_append_to(csv, send(file))
        end
        puts '--- Completed ---'
      end
    end
  end

  private

  ACTIVITIES.each do |activity|
    file_paths = "Dataset/#{activity}/*.txt"
    act = activity.downcase

    define_method "training_file_#{act}" do
      Dir.glob(file_paths).sort.first(75)
    end

    define_method "test_file_#{act}" do
      Dir.glob(file_paths).sort.last(25)
    end
  end

  def fetch_data_and_append_to(csv, file_type)
    Dir.glob(file_type) do |file|
      File.open(file).read.split(/\r\n/).map do |row|
        num = row.split(' ').map { |e| e.to_i ^ 2 }.reduce(:+)
        csv << [Math.sqrt(num).round(4)]
      end
    end
  end
end
