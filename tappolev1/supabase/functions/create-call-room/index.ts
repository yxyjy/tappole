// /supabase/functions/create-call-room/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const DAILY_API_KEY = Deno.env.get("DAILY_API_KEY")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  // 1. Handle CORS (Browser/App checks)
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 2. Parse Data from Flutter
    const { requestId, volunteerId } = await req.json();

    if (!requestId || !volunteerId) {
      throw new Error("Missing requestId or volunteerId");
    }

    // 3. Create Daily.co Room
    console.log("Creating Daily room...");
    const dailyResp = await fetch("https://api.daily.co/v1/rooms", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${DAILY_API_KEY}`,
      },
      body: JSON.stringify({
        properties: {
          exp: Math.round(Date.now() / 1000) + 3600, // Expires in 1 hour
          enable_chat: true,
        },
      }),
    });

    const dailyData = await dailyResp.json();
    if (!dailyData.url) throw new Error("Failed to create Daily room");

    const roomUrl = dailyData.url;

    // 4. Initialize Supabase Admin (Bypasses RLS)
    const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // 5. Get the Senior's ID (needed for the video_calls table)
    const { data: requestData, error: fetchError } = await supabaseAdmin
      .from("requests")
      .select("requested_by")
      .eq("req_id", requestId)
      .single();

    if (fetchError || !requestData) throw new Error("Request not found");

    const seniorId = requestData.requested_by;

    // 6. INSERT into 'video_calls' (This triggers your Flutter Listener!)
    const { error: insertError } = await supabaseAdmin
      .from("video_calls")
      .insert({
        request_id: requestId,
        initiated_by: volunteerId,
        received_by: seniorId,
        room_url: roomUrl,
        call_status: "initiated",
        started_at: new Date(),
      });

    if (insertError) throw insertError;

    // 7. UPDATE 'requests' to accepted
    await supabaseAdmin
      .from("requests")
      .update({
        req_status: "accepted",
        accepted_by: volunteerId,
        updated_at: new Date(),
      })
      .eq("req_id", requestId);

    // 8. Return URL to Volunteer
    return new Response(JSON.stringify({ roomUrl: roomUrl }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
