# frozen_string_literal: true

require 'irb'
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
    files = Dir.glob(file_paths)
    train = files.sample(75)

    define_method "training_file_#{act}" do
      train
    end

    define_method "test_file_#{act}" do
      files - train
    end
  end

  def fetch_data_and_append_to(csv, file_type)
    Dir.glob(file_type) do |file|
      vol_id = File.basename(file, File.extname(file)).split('-').last
      File.open(file).read.split(/\r\n/).map do |row|
        csv << [calculate_vector_magnitue(row), vol_id]
      end
    end
  end

  def calculate_vector_magnitue(row)
    # row.split(' ').map { |e| calibrate(e) }.reduce(:+)
    Math.sqrt(row.split(' ').map { |e| calibrate(e) }.reduce(:+))
  end

  def calibrate(e)
    (-1.5 * 9.8 + e.to_f / 63 * 3 * 9.8)**2
  end
end
