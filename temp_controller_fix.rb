  # SUBSTITUA O MÉTODO diet_pdf NO CLIENTS CONTROLLER POR ESTE:
  def diet_pdf
    @diets = @client.diets.includes(:diet_foods, :foods).order(:meal_type)
    @daily_totals = calculate_daily_totals(@diets)
    
    respond_to do |format|
      format.html { render template: 'clients/diet_pdf', layout: 'application' }
      format.pdf do
        render pdf: "dieta_#{@client.name.parameterize}",
               template: 'clients/diet_pdf.html.erb',
               layout: 'pdf.html.erb',
               page_size: 'A4',
               encoding: 'UTF-8',
               show_as_html: params[:debug].present?
      end
    end
  end
