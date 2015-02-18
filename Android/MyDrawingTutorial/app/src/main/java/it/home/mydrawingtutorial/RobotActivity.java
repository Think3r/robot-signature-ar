package it.home.mydrawingtutorial;

import android.app.ProgressDialog;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.v7.app.ActionBarActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;

import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketException;
import java.util.ArrayList;
import java.util.Enumeration;

/**
 * Created by tank on 01/02/15.
 */
public class RobotActivity extends ActionBarActivity {

    private ProgressDialog mProgressDialog, waitConnectionDialog;
    private Button sendDataButton, sendOKButton, cartesianoButton, cilindricoButton, sfericoButton, stanfordButton;
    private ImageView imageView;

    static boolean capture = true;

    ServerSocket serverSocket;
    static Socket socket;

    DataTask dataTask = null;
    OKTask okTask = null;
    RobotTask robotTask = null;

    int robot;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_robot);

        imageView = (ImageView)findViewById(R.id.imageView);
        imageView.setImageDrawable(MainActivity.canvasBitmapDrawable);

        mProgressDialog = new ProgressDialog(this);
        mProgressDialog.setIndeterminate(false);
        mProgressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);

        waitConnectionDialog = new ProgressDialog(this);
        waitConnectionDialog.setIndeterminate(false);
        waitConnectionDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
        waitConnectionDialog.setMessage("Waiting for client connection..");

        sendDataButton = (Button)findViewById(R.id.sendDataButton);
        sendDataButton.setEnabled(false);

        sendOKButton = (Button)findViewById(R.id.sendOKButton);
        sendOKButton.setEnabled(false);

        cartesianoButton = (Button)findViewById(R.id.cartesianoButton);
        cartesianoButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                robot = 2;
                sendDataButton.setEnabled(true);
                robotTask = new RobotTask();
                robotTask.execute();
            }
        });

        cilindricoButton = (Button)findViewById(R.id.cilindricoButton);
        cilindricoButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                robot = 3;
                sendDataButton.setEnabled(true);
                robotTask = new RobotTask();
                robotTask.execute();
            }
        });

        sfericoButton = (Button)findViewById(R.id.sfericoButton);
        sfericoButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                robot = 5;
                sendDataButton.setEnabled(true);
                robotTask = new RobotTask();
                robotTask.execute();
            }
        });

        stanfordButton = (Button)findViewById(R.id.stanfordButton);
        stanfordButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                robot = 6;
                sendDataButton.setEnabled(true);
                robotTask = new RobotTask();
                robotTask.execute();
            }
        });

        Thread socketServerThread = new Thread(new SocketServerThread());
        socketServerThread.start();

        waitConnectionDialog.show();

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        if (serverSocket != null) {
            try {
                serverSocket.close();
                Log.d("TANK", "Server socket closed");
            } catch (IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
    }

    public void sendData(View view){

        capture = false;
        dataTask = new DataTask();
        dataTask.execute();
    }

    public void sendOK(View view){

        okTask = new OKTask();
        okTask.execute();
    }

    private class SocketServerThread extends Thread {

        static final int SocketServerPORT = 1337;
        int count = 0;

        @Override
        public void run() {

            try {
                serverSocket = new ServerSocket(SocketServerPORT);

                Log.d("TANK","I'm waiting here: "+serverSocket.getLocalPort());

                while (true) {
                    socket = serverSocket.accept();
                    waitConnectionDialog.dismiss();
                    count++;

                    Log.d("TANK", "Connected"+count+" client; last from "+socket.getInetAddress());

                    RobotActivity.this.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            sendDataButton.setEnabled(true);
                            sendOKButton.setEnabled(false);
                        }
                    });
                }

            } catch (IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }

    }

    /**
     * Represents an asynchronous task used to send data to the client.
     */
    public class DataTask extends AsyncTask<Void, Void, String> {

        @Override
        protected void onPreExecute() {
            mProgressDialog.setMessage("Sending data..");
            mProgressDialog.show();
        }

        @Override
        protected String doInBackground(Void... params) {

            Log.d("TANK", "sendData");

            SocketServerReplyThread socketServerReplyThread = new SocketServerReplyThread(socket, "DATA");
            socketServerReplyThread.run();

            return "Done";//sendData(DrawingView.track, dstAddress, dstPort, response);
        }

        @Override
        protected void onPostExecute(final String result) {
            mProgressDialog.dismiss();
        }

    }

    /**
     * Represents an asynchronous task used to send data to the client.
     */
    public class OKTask extends AsyncTask<Void, Void, String> {

        @Override
        protected void onPreExecute() {

            mProgressDialog.setMessage("Sending OK..");
            mProgressDialog.show();
        }

        @Override
        protected String doInBackground(Void... params) {

            Log.d("TANK", "sendOK");

            SocketServerReplyThread socketServerReplyThread = new SocketServerReplyThread(socket, "OK");
            socketServerReplyThread.run();

            return "Done";//sendData(DrawingView.track, dstAddress, dstPort, response);
        }

        @Override
        protected void onPostExecute(final String result) {
            mProgressDialog.dismiss();
            sendOKButton.setEnabled(true);
        }

    }

    /**
     * Represents an asynchronous task used to send data to the client.
     */
    public class RobotTask extends AsyncTask<Void, Void, String> {

        @Override
        protected void onPreExecute() {

            mProgressDialog.setMessage("Sending ROBOT..");
            mProgressDialog.show();
        }

        @Override
        protected String doInBackground(Void... params) {

            Log.d("TANK", "sendRobot");

            SocketServerReplyThread socketServerReplyThread = new SocketServerReplyThread(socket, "ROBOT");
            socketServerReplyThread.run();

            return "Done";//sendData(DrawingView.track, dstAddress, dstPort, response);
        }

        @Override
        protected void onPostExecute(final String result) {
            mProgressDialog.dismiss();
            sendOKButton.setEnabled(true);
        }

    }

    private class SocketServerReplyThread extends Thread {

        private Socket hostThreadSocket;
        private String msg = "";

        SocketServerReplyThread(Socket socket, String msg) {

            hostThreadSocket = socket;
            this.msg = msg;
        }

        @Override
        public void run() {

            OutputStream outputStream;
            String out;

            if(msg.equals("DATA")){

                try {
                    outputStream = hostThreadSocket.getOutputStream();
                    PrintStream printStream = new PrintStream(outputStream, false);

                    ArrayList<DrawingView.TrackData> track = DrawingView.track;
                    for(int i=0;i<track.size(); i++) {
                        out = getData(track.get(i));
                        printStream.println(out);
                        printStream.flush();
                        Log.d("DATA", out);
                    }
                    //printStream.close();
                //message += "replayed: " + msgReply + "\n";

                RobotActivity.this.runOnUiThread(new Runnable() {

                    @Override
                    public void run() {
                        sendOKButton.setEnabled(true);
                    }
                });


                } catch (IOException e) {
                    e.printStackTrace();
                    Log.d("TANK", "Something wrong! " + e.toString());
                }

            }else if(msg.equals("OK")){

                try {
                    outputStream = hostThreadSocket.getOutputStream();
                    PrintStream printStream = new PrintStream(outputStream, false);

                    out = "OK";
                    printStream.println(out);
                    printStream.flush();
                    Log.d("OK", out);

                } catch (IOException e) {
                    e.printStackTrace();
                    Log.d("TANK", "Something wrong! " + e.toString());
                }

            }else if(msg.equals("ROBOT")){

                try {
                    outputStream = hostThreadSocket.getOutputStream();
                    PrintStream printStream = new PrintStream(outputStream, false);

                    out = "ROBOT"+robot;
                    printStream.println(out);
                    printStream.flush();
                    Log.d("ROBOT", out);

                } catch (IOException e) {
                    e.printStackTrace();
                    Log.d("TANK", "Something wrong! " + e.toString());
                }
            }


        }

        /*
        private String getIpAddress() {
            String ip = "";
            try {
                Enumeration<NetworkInterface> enumNetworkInterfaces = NetworkInterface
                        .getNetworkInterfaces();
                while (enumNetworkInterfaces.hasMoreElements()) {
                    NetworkInterface networkInterface = enumNetworkInterfaces
                            .nextElement();
                    Enumeration<InetAddress> enumInetAddress = networkInterface
                            .getInetAddresses();
                    while (enumInetAddress.hasMoreElements()) {
                        InetAddress inetAddress = enumInetAddress.nextElement();

                        if (inetAddress.isSiteLocalAddress()) {
                            ip += "SiteLocalAddress: "
                                    + inetAddress.getHostAddress() + "\n";
                        }

                    }

                }

            } catch (SocketException e) {
                e.printStackTrace();
                ip += "Something Wrong! " + e.toString() + "\n";
            }

            return ip;
        }
        */

    }

    public String getData(DrawingView.TrackData t){
        return t.getPoint().x+";"+t.getPoint().y+";"+String.valueOf(t.getTime()).substring(6);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

}
