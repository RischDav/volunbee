class MatchingController < ApplicationController
    skip_before_action :authenticate_user!, only: [:index, :results]
    layout 'volunteer'
    def index
    end
    def results
        # Get user skill scores from the frontend
        user_skills = {
          creative: params[:creative]&.to_i || 0,
          technical: params[:technical]&.to_i || 0,
          social: params[:social]&.to_i || 0,
          language: params[:language]&.to_i || 0,
          flexibility: params[:flexibility]&.to_i || 0
        }
    
        # Find matching positions
        @matching_positions = calculate_position_matches(user_skills)
        @user_skills = user_skills
    
        respond_to do |format|
          format.html # results.html.erb
          format.json { render json: { matches: @matching_positions, user_skills: @user_skills } }
        end
    end
    
    private
    
    def calculate_position_matches(user_skills, limit: 5)
    # Get all active and released positions with their organizations
    positions = Position.joins(:organization)
                        .where(released: true, online: true)
                        .where(organizations: { is_approved: true, is_deactivated: [false, nil] })

    # Calculate match scores for each position
    scored_positions = positions.map do |position|
        score = calculate_match_score(user_skills, position)
        {
        position: position,
        organization: position.organization,
        score: score,
        percentage: [score, 0].max # Don't show negative percentages
        }
    end

    # Sort by score (highest first) and return top matches
    scored_positions.sort_by { |match| -match[:score] }.first(limit)
    end

    def calculate_match_score(user_skills, position)
    base_score = 100
    
    # Map user skills to position skill columns
    skill_mappings = {
        creative: position.creative_skills,
        technical: position.technical_skills,
        social: position.social_skills,
        language: position.language_skills,
        flexibility: position.flexibility
    }

    # Calculate score based on differences
    skill_mappings.each do |user_skill, position_requirement|
        next if position_requirement.nil?
        
        user_score = user_skills[user_skill] || 0
        difference = (position_requirement - user_score).abs
        base_score -= difference * 3 # Subtract 3 points per point of difference
    end

    base_score
    end
end

    