class ApplicationJob < ActiveJob::Base

  def deserialize(job_data)
    sanitized_data = recursive_delete_gids(job_data)
    super(sanitized_data)
  end

  private

  def recursive_delete_gids(hash)
    hash.each do |key, value|
      case value
      when String
        hash.delete(key) if value.start_with? 'gid://'
      when Hash
        recursive_delete_gids(value)
      when Array
        value.each do |array_value|
          recursive_delete_gids(array_value) if array_value.is_a? Hash
        end
      end
    end
  end
end
