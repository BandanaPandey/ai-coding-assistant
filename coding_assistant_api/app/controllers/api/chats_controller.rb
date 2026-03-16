# app/controllers/api/chats_controller.rb
class Api::ChatsController < Api::BaseController
  def create
    chat = current_user.chat_sessions.create!(title: "New Chat")
    render json: chat
  end

  def message
    chat = current_user.chat_sessions.find(params[:id])

    puts("inside message action")

    user_payload = {
      code: params[:code],
      task_type: params[:task_type],
      file_path: params[:file_path],
      repo_path: params[:repo_path],
      language: params[:language],
      surrounding_code: params[:surrounding_code]
    }

    repository = current_user.repositories.find_by(
      repo_path: params[:repo_path]
    )

    unless repository
      return render json: { error: "Repository not registered" }, status: 404
    end
    
    chat.messages.create!(
      role: "user",
      content: user_payload.to_json
    )

    ai_response = generate_ai_response(repository, chat, user_payload)

    chat.messages.create!(
      role: "assistant",
      content: ai_response
    )

    render json: { response: ai_response }
  end

  private

  def generate_ai_response(repository, chat, payload)
    #rag_context = retrieve_repo_context(payload)
    rag_context = Rag::ContextAssembler.new(
          current_user: current_user,
          repository: repository,
          code: payload[:message],
          task_type: payload[:task_type]
        ).build_context
    #rag_context = []

    puts("RAG context: #{rag_context}")

    prompt = build_prompt(
      chat: chat,
      payload: payload,
      rag_context: rag_context
    )

    puts("Generated prompt: #{prompt}")
    
    Llm::Client.new.generate(
    prompt: prompt,
    task_type: payload[:task_type],
    selected_code: payload[:code],
    rag_results: rag_context
  )
  end

  def build_prompt(chat:, payload:, rag_context:)

    history = chat.messages.last(10).map do |m|
      "#{m.role.upcase}: #{m.content}"
    end.join("\n")

    context = {
      history: history,
      code: payload[:code],
      surrounding_code: payload[:surrounding_code],
      file_path: payload[:file_path],
      language: payload[:language],
      rag_context: rag_context
    }

    Llm::PromptBuilder.new(context, payload[:task_type]).build
  end

  def retrieve_repo_context(payload)

    query = [
      payload[:code],
      payload[:surrounding_code]
    ].join("\n")

    Rag::Retriever.search(query)
  end

end