class DailyListGenerator < ApplicationService
  def initialize(date: Date.current)
    @date = date
    super()
  end

  def execute
    return service_response(false, "Daily list already exists for #{@date}") if daily_list_exists?

    daily_list = create_daily_list
    generate_summary(daily_list)
    
    Rails.logger.info "Generated daily list for #{@date} with ID #{daily_list.id}"
    service_response(true, daily_list)
  rescue StandardError => e
    Rails.logger.error "Failed to generate daily list for #{@date}: #{e.message}"
    service_response(false, e.message)
  end

  private

  attr_reader :date

  def daily_list_exists?
    DailyList.exists?(date: @date)
  end

  def create_daily_list
    DailyList.create!(
      date: @date,
      status: 'generated',
      summary: initial_summary
    )
  end

  def initial_summary
    {
      total_immortals: User.immortal.active.count,
      total_ancients: User.ancient.active.count,
      available_positions: DailyList::POSITIONS,
      generated_at: Time.current.iso8601
    }
  end

  def generate_summary(daily_list)
    summary = daily_list.summary.merge(
      confirmed_presences: 0,
      pending_positions: DailyList::POSITIONS.dup,
      last_updated: Time.current.iso8601
    )
    
    daily_list.update!(summary: summary)
  end
end