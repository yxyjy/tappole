import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const ASSEMBLY_KEY = Deno.env.get("ASSEMBLYAI_API_KEY")!;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS")
    return new Response("ok", { headers: corsHeaders });

  try {
    const { audioUrl } = await req.json();
    if (!audioUrl) throw new Error("Missing audioUrl");

    // 1. Request Transcription
    console.log("Submitting to AssemblyAI...", audioUrl);
    const startResp = await fetch("https://api.assemblyai.com/v2/transcript", {
      method: "POST",
      headers: {
        authorization: ASSEMBLY_KEY,
        "content-type": "application/json",
      },
      body: JSON.stringify({
        audio_url: audioUrl,
        // 💡 NEW: Enable Auto-Title Generation
        summarization: true,
        summary_model: "informative",
        summary_type: "headline", // Generates a 5-10 word title
      }),
    });

    const startData = await startResp.json();
    const transcriptId = startData.id;

    // 2. Poll for Completion (Simple loop)
    let transcriptText = "";
    let title = "";
    while (true) {
      // Wait 1 second
      await new Promise((r) => setTimeout(r, 1000));

      const checkResp = await fetch(
        `https://api.assemblyai.com/v2/transcript/${transcriptId}`,
        {
          headers: { authorization: ASSEMBLY_KEY },
        }
      );
      const checkData = await checkResp.json();

      if (checkData.status === "completed") {
        transcriptText = checkData.text;
        title = checkData.summary || "New Request";
        break;
      } else if (checkData.status === "error") {
        throw new Error("Transcription failed: " + checkData.error);
      }
    }

    return new Response(
      JSON.stringify({ text: transcriptText, title: title }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);

    return new Response(JSON.stringify({ error: message }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
