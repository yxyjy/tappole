import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS")
    return new Response("ok", { headers: corsHeaders });

  try {
    const body = await req.json();
    console.log("1. Received Body:", body); // 🔍 LOG INPUT

    const { requestId, volunteerId } = body;

    const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // --- DEBUG CHECK 1: Check if Request Exists ---
    const { data: requestData, error: fetchError } = await supabaseAdmin
      .from("requests")
      .select("*") // Select all to see what we found
      .eq("req_id", requestId)
      .single();

    if (fetchError) {
      console.error("2. Fetch Error:", fetchError); // 🔍 LOG ERROR
      throw new Error(`Fetch failed: ${fetchError.message}`);
    }
    if (!requestData) {
      console.error("2. Request Not Found for ID:", requestId);
      throw new Error("Request ID does not exist in DB");
    }
    console.log("2. Found Request:", requestData); // 🔍 LOG DATA

    // --- DEBUG CHECK 2: Insert Video Call ---
    const { error: insertError } = await supabaseAdmin
      .from("video_calls")
      .insert({
        request_id: requestId,
        initiated_by: volunteerId,
        received_by: requestData.requested_by,
        call_status: "initiated",
        started_at: new Date(),
      });

    if (insertError) {
      console.error("3. Insert Error:", insertError); // 🔍 LOG ERROR
      throw new Error(`Video Call Insert failed: ${insertError.message}`);
    }
    console.log("3. Video Call Inserted");

    // --- DEBUG CHECK 3: Update Request ---
    // Note: Ensure 'req_status' is the correct column name!
    const { error: updateError } = await supabaseAdmin
      .from("requests")
      .update({ req_status: "accepted", accepted_by: volunteerId })
      .eq("req_id", requestId);

    if (updateError) {
      console.error("4. Update Error:", updateError); // 🔍 LOG ERROR
      throw new Error(`Request Update failed: ${updateError.message}`);
    }
    console.log("4. Request Updated");

    return new Response(JSON.stringify({ success: true, callId: requestId }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("FATAL ERROR:", error);
    return new Response(
      JSON.stringify({ error: error.message, details: "Check Function Logs" }),
      {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
