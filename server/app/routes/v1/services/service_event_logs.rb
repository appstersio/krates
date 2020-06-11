V1::ServicesApi.route('service_event_logs') do |r|

  # GET /v1/services/:grid_name/:service_name/event_logs
  r.get do
    r.is do
      # Switch to use newer syntax
      scope = EventLog.with(read: { mode: :secondary_preferred }) do |klass|
        klass.where(grid_service_id: @grid_service.id)
          .includes(:grid, :stack, :grid_service, :host_node)
      end

      render_event_logs(r, scope)
    end
  end
end
